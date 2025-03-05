package com.amastsales.flutter_sf380r_printer

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.*
import java.lang.reflect.Method

class BluetoothScanner(private val context: Context, private val deviceList: BluetoothDeviceList) {
    private val TAG = "BluetoothScanner"

    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter
    }

    private var isScanning = false
    private val handler = Handler(Looper.getMainLooper())
    private var methodChannel: MethodChannel? = null

    // Define the BroadcastReceiver for device discovery
    private val discoveryReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                BluetoothDevice.ACTION_FOUND -> {
                    // Get the BluetoothDevice object from the Intent
                    val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                    }

                    device?.let {
                        // Add the device to our list
                        deviceList.addDevice(it)

                        // Create a map to send to Flutter
                        val deviceMap = mapOf(
                                "name" to (it.name ?: "Unknown"),
                                "address" to it.address,
                                "type" to it.bluetoothClass.deviceClass,
                                "isPrinter" to (it.bluetoothClass.majorDeviceClass == android.bluetooth.BluetoothClass.Device.Major.IMAGING)
                        )

                        // Send the device to Flutter
                        methodChannel?.invokeMethod("onDeviceDiscovered", deviceMap)

                        Log.d(TAG, "Discovered device: ${it.name ?: "Unknown"} - ${it.address}")
                    }
                }
                BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> {
                    Log.d(TAG, "Discovery finished")
                    isScanning = false
                    methodChannel?.invokeMethod("onScanFinished", null)
                }
            }
        }
    }

    // Register for bond state changes
    private val bondStateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == BluetoothDevice.ACTION_BOND_STATE_CHANGED) {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }

                val bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.ERROR)
                val previousBondState = intent.getIntExtra(BluetoothDevice.EXTRA_PREVIOUS_BOND_STATE, BluetoothDevice.ERROR)

                Log.d(TAG, "Bond state changed for ${device?.name}: $previousBondState -> $bondState")

                if (bondState == BluetoothDevice.BOND_BONDED) {
                    // Device successfully paired
                    methodChannel?.invokeMethod("onPairingStatus", mapOf(
                            "address" to device?.address,
                            "success" to true
                    ))
                } else if (bondState == BluetoothDevice.BOND_NONE && previousBondState == BluetoothDevice.BOND_BONDING) {
                    // Pairing failed
                    methodChannel?.invokeMethod("onPairingStatus", mapOf(
                            "address" to device?.address,
                            "success" to false
                    ))
                }
            }
        }
    }

    fun setMethodChannel(channel: MethodChannel) {
        this.methodChannel = channel
    }

//    utility function to show dummy result but it does not needed
//     need to call methods that require a Result parameter, but don't actually care about the result.
    private val dummyResult = object : MethodChannel.Result {
        override fun success(result: Any?) {}
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
        override fun notImplemented() {}
    }

    @SuppressLint("MissingPermission")
    fun startScan(result: Result, timeout: Long = 10000) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }

        if (!bluetoothAdapter!!.isEnabled) {
            result.error("BLUETOOTH_DISABLED", "Bluetooth is not enabled", null)
            return
        }

        // Check for permissions on Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED) {
                result.error("PERMISSION_DENIED", "BLUETOOTH_SCAN permission is required for Android 12+", null)
                return
            }
        }

        try {
            // Register for device discovery broadcasts
            val filter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
                addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
            }
            context.registerReceiver(discoveryReceiver, filter)

            // Start discovery
            if (bluetoothAdapter!!.isDiscovering) {
                bluetoothAdapter!!.cancelDiscovery()
            }

            deviceList.clear() // Clear previous results

            // Add paired devices first
            bluetoothAdapter!!.bondedDevices.forEach { device ->
                deviceList.addDevice(device)

                // Send each paired device to Flutter
                val deviceMap = mapOf(
                        "name" to (device.name ?: "Unknown"),
                        "address" to device.address,
                        "type" to device.bluetoothClass.deviceClass,
                        "isPrinter" to (device.bluetoothClass.majorDeviceClass == android.bluetooth.BluetoothClass.Device.Major.IMAGING)
                )

                methodChannel?.invokeMethod("onDeviceDiscovered", deviceMap)
            }

            isScanning = bluetoothAdapter!!.startDiscovery()

            // Set a timeout to stop scanning
            if (timeout > 0) {
                handler.postDelayed({
                    stopScan(dummyResult)
                }, timeout)
            }

            result.success(isScanning)
        } catch (e: Exception) {
            result.error("SCAN_ERROR", e.message, null)
        }
    }

    @SuppressLint("MissingPermission")
    fun stopScan(result: Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }

        try {
            if (bluetoothAdapter!!.isDiscovering) {
                bluetoothAdapter!!.cancelDiscovery()
            }

            try {
                context.unregisterReceiver(discoveryReceiver)
            } catch (e: IllegalArgumentException) {
                // Receiver not registered, ignore
            }

            isScanning = false
            result.success(true)
        } catch (e: Exception) {
            result.error("STOP_SCAN_ERROR", e.message, null)
        }
    }

    @SuppressLint("MissingPermission")
    fun pairDevice(address: String, result: Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }

        try {
            val device = bluetoothAdapter!!.getRemoteDevice(address)

            // Check if already paired
            if (device.bondState == BluetoothDevice.BOND_BONDED) {
                result.success(true)
                return
            }

            // Register for bond state changes
            val filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
            context.registerReceiver(bondStateReceiver, filter)

            // Use reflection to initiate pairing
            val method: Method = device.javaClass.getMethod("createBond")
            val success = method.invoke(device) as Boolean

            if (!success) {
                context.unregisterReceiver(bondStateReceiver)
                result.error("PAIRING_FAILED", "Failed to initiate pairing", null)
            } else {
                // Result will be delivered through the BroadcastReceiver
                // We don't call result.success() here

                // But we need a timeout to prevent the result from hanging
                handler.postDelayed({
                    try {
                        // If we're still bonding after timeout, consider it a failure
                        if (device.bondState == BluetoothDevice.BOND_BONDING) {
                            context.unregisterReceiver(bondStateReceiver)
                            result.error("PAIRING_TIMEOUT", "Pairing operation timed out", null)
                        }
                    } catch (e: Exception) {
                        // Ignore
                    }
                }, 20000) // 20 second timeout
            }
        } catch (e: Exception) {
            result.error("PAIRING_ERROR", e.message, null)
        }
    }

    @SuppressLint("MissingPermission")
    fun isDevicePaired(address: String, result: Result) {
        if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_UNAVAILABLE", "Bluetooth is not available on this device", null)
            return
        }

        try {
            val device = bluetoothAdapter!!.getRemoteDevice(address)
            result.success(device.bondState == BluetoothDevice.BOND_BONDED)
        } catch (e: Exception) {
            result.error("CHECK_PAIRING_ERROR", e.message, null)
        }
    }

    fun cleanup() {
        try {
            if (bluetoothAdapter?.isDiscovering == true) {
                bluetoothAdapter?.cancelDiscovery()
            }

            try {
                context.unregisterReceiver(discoveryReceiver)
            } catch (e: IllegalArgumentException) {
                // Receiver not registered, ignore
            }

            try {
                context.unregisterReceiver(bondStateReceiver)
            } catch (e: IllegalArgumentException) {
                // Receiver not registered, ignore
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}