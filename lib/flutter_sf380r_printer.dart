import 'dart:async';
import 'package:flutter/services.dart';

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

  Future<bool> printText(String text) {
    return FlutterSf380rPrinterPlatform.instance.printText(text);
  }

  Future<bool> printQRCode(
    String content, {
    int moduleSize = 4,
    int height = 200,
    int position = POSITION_NONE,
  }) {
    return FlutterSf380rPrinterPlatform.instance.printQRCode(
      content,
      moduleSize: moduleSize,
      height: height,
      position: position,
    );
  }

  Future<bool> printBarcode(
    String content, {
    int type = BARCODE_CODE128,
    int width = 2,
    int height = 100,
    int position = POSITION_NONE,
  }) {
    return FlutterSf380rPrinterPlatform.instance.printBarcode(
      content,
      type: type,
      width: width,
      height: height,
      position: position,
    );
  }

  Future<bool> printImage(Uint8List imageBytes) {
    return FlutterSf380rPrinterPlatform.instance.printImage(imageBytes);
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

  Future<bool> setTextAlignment(int alignment) {
  return FlutterSf380rPrinterPlatform.instance.setTextAlignment(alignment);
  }

  Future<bool> setEncoding(String encoding) {
    return FlutterSf380rPrinterPlatform.instance.setEncoding(encoding);
  }

  Future<bool> setCharacterMultiple(int x, int y) {
    return FlutterSf380rPrinterPlatform.instance.setCharacterMultiple(x, y);
  }

  Future<bool> setPrintModel(bool smallFont, bool isBold, bool isDoubleHeight, 
                          bool isDoubleWidth, bool isUnderLine) {
    return FlutterSf380rPrinterPlatform.instance.setPrintModel(
      smallFont, isBold, isDoubleHeight, isDoubleWidth, isUnderLine
    );

  }

  

  // Helper methods
  void setCallbacks({
    Function? onConnected,
    Function? onConnectionFailed,
    Function? onDisconnected,
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
    print('Error printing receipt: $e');
    return false;
  }
}
}