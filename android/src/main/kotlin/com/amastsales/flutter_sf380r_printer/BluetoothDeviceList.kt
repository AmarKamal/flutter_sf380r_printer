package com.amastsales.flutter_sf380r_printer

import android.bluetooth.BluetoothDevice

class BluetoothDeviceList {
    private val deviceList = mutableListOf<BluetoothDevice>()

    fun addDevice(device: BluetoothDevice) {
        if (!deviceList.contains(device)) {
            deviceList.add(device)
        }
    }

    fun getDeviceList(): List<BluetoothDevice> = deviceList

    fun clear() {
        deviceList.clear()
    }

    // Add a function to find a device by address
    fun findDeviceByAddress(address: String): BluetoothDevice? {
        return deviceList.find { it.address == address }
    }
}