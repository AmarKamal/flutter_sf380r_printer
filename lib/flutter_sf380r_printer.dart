// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'package:flutter/foundation.dart';


import 'flutter_sf380r_printer_platform_interface.dart';
export 'flutter_sf380r_printer_platform_interface.dart' show BluetoothDevice;

class FlutterSf380rPrinter {
   
  // Alignment constants
  static const int ALIGN_LEFT = 0;
  static const int ALIGN_CENTER = 1;
  static const int ALIGN_RIGHT = 2;
  
  // Printer status constants
  static const int STATUS_READY = 0;
  static const int STATUS_OUT_OF_PAPER = 1;
  static const int STATUS_OPEN_LID = 2;
  static const int STATUS_ERROR = -1;

  // Barcode type constants
  static const int BARCODE_UPC_A = 0;
  static const int BARCODE_UPC_E = 1;
  static const int BARCODE_JAN13 = 2;
  static const int BARCODE_JAN8 = 3;
  static const int BARCODE_CODE39 = 4;
  static const int BARCODE_ITF = 5;
  static const int BARCODE_CODABAR = 6;
  static const int BARCODE_CODE93 = 7;
  static const int BARCODE_CODE128 = 8;

  // Text position constants
  static const int POSITION_NONE = 0;
  static const int POSITION_ABOVE = 1;
  static const int POSITION_BELOW = 2;
  static const int POSITION_BOTH = 3;

  // Callback properties
  Function? onPrinterConnected;
  Function? onPrinterConnectionFailed;
  Function? onPrinterDisconnected;

  Function(BluetoothDevice)? onDeviceDiscovered;
  Function()? onScanFinished;
  Function(String, bool)? onPairingStatus;


  FlutterSf380rPrinter() {
  if (onPrinterConnected != null) {
    FlutterSf380rPrinterPlatform.instance.registerPrinterConnectedCallback(onPrinterConnected!);
  }
  
  if (onPrinterConnectionFailed != null) {
    FlutterSf380rPrinterPlatform.instance.registerPrinterConnectionFailedCallback(onPrinterConnectionFailed!);
  }
  
  if (onPrinterDisconnected != null) {
    FlutterSf380rPrinterPlatform.instance.registerPrinterDisconnectedCallback(onPrinterDisconnected!);
  }
  
  if (onDeviceDiscovered != null) {
    FlutterSf380rPrinterPlatform.instance.registerDeviceDiscoveredCallback(onDeviceDiscovered!);
  }
  
  if (onScanFinished != null) {
    FlutterSf380rPrinterPlatform.instance.registerScanFinishedCallback(onScanFinished!);
  }
  
  if (onPairingStatus != null) {
    FlutterSf380rPrinterPlatform.instance.registerPairingStatusCallback(onPairingStatus!);
  }
}

  Future<String?> getPlatformVersion() {
    return FlutterSf380rPrinterPlatform.instance.getPlatformVersion();
  }

  Future<List<BluetoothDevice>> getBluetoothDevices() {
    return FlutterSf380rPrinterPlatform.instance.getBluetoothDevices();
  }

  Future<bool> connectBluetooth(String address) {
    return FlutterSf380rPrinterPlatform.instance.connectBluetooth(address);
  }

  Future<bool> disconnect() {
    return FlutterSf380rPrinterPlatform.instance.disconnect();
  }

  Future<bool> printText(
    String text, {
    int alignment = ALIGN_LEFT,
    bool bold = false,
    bool underline = false,
    bool doubleWidth = false,
    bool doubleHeight = false,
    bool smallFont = false,
  }) {
    return FlutterSf380rPrinterPlatform.instance.printText(
      text,
      alignment: alignment,
      bold: bold,
      underline: underline,
      doubleWidth: doubleWidth,
      doubleHeight: doubleHeight,
      smallFont: smallFont,
    );
  }

  Future<bool> printQRCode(
    String content, {
    int moduleSize = 4,    
    int alignment = ALIGN_LEFT,
  }) {
    return FlutterSf380rPrinterPlatform.instance.printQRCode(
      content,
      moduleSize: moduleSize,
      alignment: alignment,
      
    );
  }

  Future<bool> printBarcode(
    String content, {
    int type = BARCODE_CODE128,
    int width = 2,
    int height = 100,
    int position = POSITION_NONE,
    int alignment = ALIGN_LEFT,
  }) {
    return FlutterSf380rPrinterPlatform.instance.printBarcode(
      content,
      type: type,
      width: width,
      height: height,
      position: position,
      alignment: alignment,
    );
  }

  Future<bool> printImage(Uint8List imageBytes, {int alignment = ALIGN_LEFT}) {
    return FlutterSf380rPrinterPlatform.instance.printImage(imageBytes, alignment: alignment);
  }

  Future<bool> printTable(
    List<String> columns,
    List<int> columnWidths,
    List<List<String>> rows,
  ) {
    return FlutterSf380rPrinterPlatform.instance.printTable(
      columns,
      columnWidths,
      rows,
    );
  }

  Future<int> getPrinterStatus() {
    return FlutterSf380rPrinterPlatform.instance.getPrinterStatus();
  }

  Future<bool> setEncoding(String encoding) {
    return FlutterSf380rPrinterPlatform.instance.setEncoding(encoding);
  }

  // Start scanning for Bluetooth devices
  Future<bool> startScan({Duration timeout = const Duration(seconds: 10)}) {
    return FlutterSf380rPrinterPlatform.instance.startScan(timeout: timeout);
  }

  // Stop scanning for Bluetooth devices
  Future<bool> stopScan() {
    return FlutterSf380rPrinterPlatform.instance.stopScan();
  }

  // Pair with a Bluetooth device
  Future<bool> pairDevice(String address) {
    return FlutterSf380rPrinterPlatform.instance.pairDevice(address);
  }

  // Check if a device is paired
  Future<bool> isDevicePaired(String address) {
    return FlutterSf380rPrinterPlatform.instance.isDevicePaired(address);
  }

  // Helper methods
  // Helper methods
void setCallbacks({
  Function? onConnected,
  Function? onConnectionFailed,
  Function? onDisconnected,
  Function(BluetoothDevice)? onDiscovered,
  Function()? onScanComplete,
  Function(String, bool)? onPaired,
}) {
  if (onConnected != null) {
    onPrinterConnected = onConnected;
    FlutterSf380rPrinterPlatform.instance.registerPrinterConnectedCallback(onConnected);
  }
  
  if (onConnectionFailed != null) {
    onPrinterConnectionFailed = onConnectionFailed;
    FlutterSf380rPrinterPlatform.instance.registerPrinterConnectionFailedCallback(onConnectionFailed);
  }
  
  if (onDisconnected != null) {
    onPrinterDisconnected = onDisconnected;
    FlutterSf380rPrinterPlatform.instance.registerPrinterDisconnectedCallback(onDisconnected);
  }
  
  if (onDiscovered != null) {
    onDeviceDiscovered = onDiscovered;
    FlutterSf380rPrinterPlatform.instance.registerDeviceDiscoveredCallback(onDiscovered);
  }
  
  if (onScanComplete != null) {
    onScanFinished = onScanComplete;
    FlutterSf380rPrinterPlatform.instance.registerScanFinishedCallback(onScanComplete);
  }
  
  if (onPaired != null) {
    onPairingStatus = onPaired;
    FlutterSf380rPrinterPlatform.instance.registerPairingStatusCallback(onPaired);
  }
}

  // Additional helper methods

  // Print a simple receipt
  Future<bool> printReceipt({
  required String header,
  required List<Map<String, dynamic>> items,
  required double total,
  String? footer,
  String? qrData,
}) async {
  try {
    // Print header
    await printText('\n$header\n\n');

    // Print items
    List<String> columns = ['Item', 'Qty', 'Price'];
    List<int> columnWidths = [16, 6, 8];
    
    // Fix: Explicitly cast to List<List<String>>
    List<List<String>> rows = items.map((item) => [
      item['name'].toString(),
      item['quantity'].toString(),
      item['price'].toStringAsFixed(2),
    ]).toList().cast<List<String>>();
    
    await printTable(columns, columnWidths, rows);

    // Print total
    await printText('\nTotal: ${total.toStringAsFixed(2)}\n\n');

    // Print footer if provided
    if (footer != null && footer.isNotEmpty) {
      await printText('$footer\n\n');
    }

    // Print QR code if provided
    if (qrData != null && qrData.isNotEmpty) {
      await printQRCode(qrData);
    }

    // Feed paper
    await printText('\n\n\n\n');
    
    return true;
  } catch (e) {
    debugPrint('Error printing receipt: $e');
    return false;
  }
}
}