import 'dart:async';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_sf380r_printer_platform_interface.dart';

class MethodChannelFlutterSf380rPrinter extends FlutterSf380rPrinterPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_sf380r_printer');

  // Callback registrations
  Function? _onPrinterConnectedCallback;
  Function? _onPrinterConnectionFailedCallback;
  Function? _onPrinterDisconnectedCallback;

  MethodChannelFlutterSf380rPrinter() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onPrinterConnected':
        if (_onPrinterConnectedCallback != null) {
          _onPrinterConnectedCallback!();
        }
        break;
      case 'onPrinterConnectionFailed':
        if (_onPrinterConnectionFailedCallback != null) {
          _onPrinterConnectionFailedCallback!();
        }
        break;
      case 'onPrinterDisconnected':
        if (_onPrinterDisconnectedCallback != null) {
          _onPrinterDisconnectedCallback!();
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<BluetoothDevice>> getBluetoothDevices() async {
    final List<dynamic> devices = await methodChannel.invokeMethod('getBluetoothDevices');
    return devices.map((device) => BluetoothDevice.fromMap(device)).toList();
  }

  @override
  Future<bool> connectBluetooth(String address) async {
    return await methodChannel.invokeMethod('connectBluetooth', {
      'address': address,
    });
  }

  @override
  Future<bool> disconnect() async {
    return await methodChannel.invokeMethod('disconnect');
  }



  @override
  Future<bool> printText(
    String text, {
    int alignment = 0,
    bool bold = false,
    bool underline = false,
    bool doubleWidth = false,
    bool doubleHeight = false,
    bool smallFont = false,
  }) async {
    return await methodChannel.invokeMethod('printText', {
      'text': text,
      'alignment': alignment,
      'bold': bold,
      'underline': underline,
      'doubleWidth': doubleWidth,
      'doubleHeight': doubleHeight,
      'smallFont': smallFont,
    });
  }

  @override
  Future<bool> printQRCode(
    String content, {
    int moduleSize = 4,
    int alignment = 0,
  }) async {
    return await methodChannel.invokeMethod('printQRCode', {
      'content': content,
      'moduleSize': moduleSize,
      'alignment': alignment,
    });
  }

  @override
  Future<bool> printBarcode(
    String content, {
    int type = 8,
    int width = 2,
    int height = 100,
    int position = 0,
    int alignment = 0,
  }) async {
    return await methodChannel.invokeMethod('printBarcode', {
      'content': content,
      'type': type,
      'width': width,
      'height': height,
      'position': position,
      'alignment': alignment,
    });
  }

  @override
  Future<bool> printImage(Uint8List imageBytes, {int alignment = 0}) async {
    String base64Image = base64Encode(imageBytes);
    return await methodChannel.invokeMethod('printImage', {
      'base64Image': base64Image,
      'alignment': alignment,
    });
  }

  @override
  Future<bool> printTable(
    List<String> columns,
    List<int> columnWidths,
    List<List<String>> rows,
  ) async {
    return await methodChannel.invokeMethod('printTable', {
      'columns': columns,
      'columnWidths': columnWidths,
      'rows': rows,
    });
  }

  @override
  Future<int> getPrinterStatus() async {
    return await methodChannel.invokeMethod('getPrinterStatus');
  }


  @override
  void registerPrinterConnectedCallback(Function callback) {
    _onPrinterConnectedCallback = callback;
  }

  @override
  void registerPrinterConnectionFailedCallback(Function callback) {
    _onPrinterConnectionFailedCallback = callback;
  }

  @override
  void registerPrinterDisconnectedCallback(Function callback) {
    _onPrinterDisconnectedCallback = callback;
  }

  // @override
  // Future<bool> setTextAlignment(int alignment) async {
  //   return await methodChannel.invokeMethod('setTextAlignment', {
  //     'alignment': alignment,
  //   });
  // }

  // @override
  // Future<bool> printWithAlignment(String text, int alignment) async {
  //   return await methodChannel.invokeMethod('printWithAlignment', {
  //     'text': text,
  //     'alignment': alignment,
  //   });
  // }

  @override
  Future<bool> setEncoding(String encoding) async {
    return await methodChannel.invokeMethod('setEncoding', {
      'encoding': encoding,
    });
  }

  // @override
  // Future<bool> setCharacterMultiple(int x, int y) async {
  //   return await methodChannel.invokeMethod('setCharacterMultiple', {
  //     'x': x,
  //     'y': y,
  //   });
  // }

  // @override
  // Future<bool> printBoldText(String text, {bool bold = true}) async {
  //   return await methodChannel.invokeMethod('printBoldText', {
  //     'text': text,
  //     'bold': bold,
  //   });
  // }

  // @override
  // Future<bool> printUnderlinedText(String text, {bool underline = true}) async {
  //   return await methodChannel.invokeMethod('printUnderlinedText', {
  //     'text': text,
  //     'underline': underline,
  //   });
  // }

  // @override
  // Future<bool> printSizedText(
  //   String text, {
  //   int widthScale = 0,
  //   int heightScale = 0,
  // }) async {
  //   return await methodChannel.invokeMethod('printSizedText', {
  //     'text': text,
  //     'widthScale': widthScale,
  //     'heightScale': heightScale,
  //   });
  // }

  // @override
  // Future<bool> printFormattedText(
  //   String text, {
  //   int alignment = 0,
  //   bool bold = false,
  //   bool underline = false,
  //   bool doubleHeight = false,
  //   bool doubleWidth = false,
  //   bool smallFont = false,
  // }) async {
  //   return await methodChannel.invokeMethod('printFormattedText', {
  //     'text': text,
  //     'alignment': alignment,
  //     'bold': bold,
  //     'underline': underline,
  //     'doubleHeight': doubleHeight,
  //     'doubleWidth': doubleWidth,
  //     'smallFont': smallFont,
  //   });
  // }

  // @override
  // Future<bool> setPrintModel(bool smallFont, bool isBold, bool isDoubleHeight, 
  //                         bool isDoubleWidth, bool isUnderLine) async {
  //   return await methodChannel.invokeMethod('setPrintModel', {
  //     'smallFont': smallFont,
  //     'isBold': isBold,
  //     'isDoubleHeight': isDoubleHeight,
  //     'isDoubleWidth': isDoubleWidth,
  //     'isUnderLine': isUnderLine,
  //   });
  // }

  // @override
  // Future<bool> printWithFontProperty(
  //   String text, {
  //   bool bold = false,
  //   bool italic = false,
  //   bool underline = false,
  //   int size = 24,
  //   String? fontFamily,
  // }) async {
  //   return await methodChannel.invokeMethod('printWithFontProperty', {
  //     'text': text,
  //     'bold': bold,
  //     'italic': italic,
  //     'underline': underline,
  //     'size': size,
  //     'fontFamily': fontFamily,
  //   });
  // }

  
}