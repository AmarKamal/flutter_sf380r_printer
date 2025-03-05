package com.amastsales.flutter_sf380r_printer

import android.bluetooth.BluetoothClass
import android.content.Context
import android.bluetooth.BluetoothManager

import android.os.Handler
import android.os.Looper

import com.mht.print.sdk.PrinterConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterSf380rPrinterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var bluetoothOperation: BluetoothOperation
  private lateinit var deviceList: BluetoothDeviceList
  private lateinit var bluetoothScanner: BluetoothScanner
  private lateinit var handler: Handler

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_sf380r_printer")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext

    deviceList = BluetoothDeviceList()
    bluetoothScanner = BluetoothScanner(context, deviceList)
    bluetoothScanner.setMethodChannel(channel)

    handler = Handler(Looper.getMainLooper()) { msg ->
      when (msg.what) {
        PrinterConstants.Connect.SUCCESS ->
          channel.invokeMethod("onPrinterConnected", null)
        PrinterConstants.Connect.FAILED ->
          channel.invokeMethod("onPrinterConnectionFailed", null)
        PrinterConstants.Connect.CLOSED ->
          channel.invokeMethod("onPrinterDisconnected", null)
      }
      true
    }

    bluetoothOperation = BluetoothOperation(context, handler)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      "getBluetoothDevices" -> {
        try {
          val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
          val bluetoothAdapter = bluetoothManager.adapter
          if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_ERROR", "Bluetooth not available", null)
            return
          }

          // Check if Bluetooth is enabled
          if (!bluetoothAdapter.isEnabled) {
            result.error("BLUETOOTH_ERROR", "Bluetooth is not enabled", null)
            return
          }

          // Get paired devices
          val pairedDevices = bluetoothAdapter.bondedDevices

          // Clear and add devices to your deviceList
          deviceList.clear() // Clear previous devices
          for (device in pairedDevices) {
            deviceList.addDevice(device)
          }

          val devicesList = pairedDevices.map { device ->
            mapOf(
                    "name" to (device.name ?: "Unknown"),
                    "address" to device.address,
                    "type" to device.bluetoothClass.deviceClass,
                    "isPrinter" to (device.bluetoothClass.majorDeviceClass == BluetoothClass.Device.Major.IMAGING)
            )
          }
          result.success(devicesList)
        } catch (e: Exception) {
          result.error("BLUETOOTH_ERROR", e.message, null)
        }
      }

      "startScan" -> {
        val timeout = call.argument<Int>("timeout") ?: 10000
        bluetoothScanner.startScan(result, timeout.toLong())
      }

      "stopScan" -> {
        bluetoothScanner.stopScan(result)
      }

      "pairDevice" -> {
        val address = call.argument<String>("address")
        if (address == null) {
          result.error("INVALID_ARGUMENT", "Bluetooth address is required", null)
          return
        }
        bluetoothScanner.pairDevice(address, result)
      }

      "isDevicePaired" -> {
        val address = call.argument<String>("address")
        if (address == null) {
          result.error("INVALID_ARGUMENT", "Bluetooth address is required", null)
          return
        }
        bluetoothScanner.isDevicePaired(address, result)
      }

      "connectBluetooth" -> {
        val address = call.argument<String>("address")
        if (address == null) {
          result.error("INVALID_ARGUMENT", "Bluetooth address is required", null)
          return
        }

        try {
          val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
          val bluetoothAdapter = bluetoothManager.adapter
          if (bluetoothAdapter == null) {
            result.error("BLUETOOTH_ERROR", "Bluetooth not available", null)
            return
          }

          val device = bluetoothAdapter.getRemoteDevice(address)
          val connected = bluetoothOperation.connectPrinter(device)
          result.success(connected)
        } catch (e: Exception) {
          result.error("CONNECTION_ERROR", e.message, null)
        }
      }

      "disconnect" -> {
        try {
          bluetoothOperation.disconnect()
          result.success(true)
        } catch (e: Exception) {
          result.error("DISCONNECT_ERROR", e.message, null)
        }
      }


      "printText" -> {
        val text = call.argument<String>("text")
        val alignment = call.argument<Int>("alignment") ?: 0
        val bold = call.argument<Boolean>("bold") ?: false
        val underline = call.argument<Boolean>("underline") ?: false
        val doubleWidth = call.argument<Boolean>("doubleWidth") ?: false
        val doubleHeight = call.argument<Boolean>("doubleHeight") ?: false
        val smallFont = call.argument<Boolean>("smallFont") ?: false

        if (text == null) {
          result.error("INVALID_ARGUMENT", "Text is required", null)
          return
        }

        try {
          val success = bluetoothOperation.printText(
                  text,
                  alignment,
                  bold,
                  underline,
                  doubleWidth,
                  doubleHeight,
                  smallFont
          )
          result.success(success)
        } catch (e: Exception) {
          result.error("PRINT_ERROR", e.message, null)
        }
      }


      "printQRCode" -> {
        val content = call.argument<String>("content") ?: ""
        val moduleSize = call.argument<Int>("moduleSize") ?: 4
        val alignment = call.argument<Int>("alignment") ?: 0

        try {
          val success = bluetoothOperation.printQRCode(content, moduleSize,alignment)
          result.success(success)
        } catch (e: Exception) {
          result.error("QR_CODE_ERROR", e.message, null)
        }
      }

      "printBarcode" -> {
        val content = call.argument<String>("content") ?: ""
        val type = call.argument<Int>("type") ?: 8  // Default to CODE128
        val width = call.argument<Int>("width") ?: 2
        val height = call.argument<Int>("height") ?: 100
        val position = call.argument<Int>("position") ?: 0
        val alignment = call.argument<Int>("alignment") ?: 0

        try {
          val success = bluetoothOperation.printBarcode(content, type, width, height, position,alignment)
          result.success(success)
        } catch (e: Exception) {
          result.error("BARCODE_ERROR", e.message, null)
        }
      }

      "printImage" -> {
        val base64Image = call.argument<String>("base64Image")
        val alignment  = call.argument<Int>("alignment") ?: 0 // Default to left alignment

        if (base64Image == null) {
          result.error("INVALID_ARGUMENT", "Image data is required", null)
          return
        }

        try {
          val success = bluetoothOperation.printImage(base64Image,alignment)
          result.success(success)
        } catch (e: Exception) {
          result.error("IMAGE_ERROR", e.message, null)
        }
      }

      "printTable" -> {
        val columns = call.argument<List<String>>("columns")
        val columnWidths = call.argument<List<Int>>("columnWidths")
        val rows = call.argument<List<List<String>>>("rows")

        if (columns == null || columnWidths == null || rows == null) {
          result.error("INVALID_ARGUMENT", "Columns, column widths, and rows are required", null)
          return
        }

        if (columns.size != columnWidths.size) {
          result.error("INVALID_ARGUMENT", "Column count must match column widths count", null)
          return
        }

        try {
          val success = bluetoothOperation.printTable(columns, columnWidths, rows)
          result.success(success)
        } catch (e: Exception) {
          result.error("TABLE_ERROR", e.message, null)
        }
      }

      "getPrinterStatus" -> {
        try {
          val status = bluetoothOperation.getPrinterStatus()
          result.success(status)
        } catch (e: Exception) {
          result.error("STATUS_ERROR", e.message, null)
        }
      }

      "setEncoding" -> {
        val encoding = call.argument<String>("encoding") ?: "gbk"
        try {
          val success = bluetoothOperation.setEncoding(encoding)
          result.success(success)
        } catch (e: Exception) {
          result.error("ENCODING_ERROR", e.message, null)
        }
      }


      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    bluetoothOperation.disconnect()
    bluetoothScanner.cleanup()
  }
}