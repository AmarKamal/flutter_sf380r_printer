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
  Future<bool> printText(String text) async {
    return await methodChannel.invokeMethod('printText', {
      'text': text,
    });
  }

  @override
  Future<bool> printQRCode(
    String content, {
    int moduleSize = 4,
    int height = 200,
    int position = 0,
  }) async {
    return await methodChannel.invokeMethod('printQRCode', {
      'content': content,
      'moduleSize': moduleSize,
      'height': height,
      'position': position,
    });
  }

  @override
  Future<bool> printBarcode(
    String content, {
    int type = 8,
    int width = 2,
    int height = 100,
    int position = 0,
  }) async {
    return await methodChannel.invokeMethod('printBarcode', {
      'content': content,
      'type': type,
      'width': width,
      'height': height,
      'position': position,
    });
  }

  @override
  Future<bool> printImage(Uint8List imageBytes) async {
    String base64Image = base64Encode(imageBytes);
    return await methodChannel.invokeMethod('printImage', {
      'base64Image': base64Image,
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

  @override
Future<bool> setTextAlignment(int alignment) async {
  return await methodChannel.invokeMethod('setTextAlignment', {
    'alignment': alignment,
  });
}

@override
Future<bool> setEncoding(String encoding) async {
  return await methodChannel.invokeMethod('setEncoding', {
    'encoding': encoding,
  });
}

@override
Future<bool> setCharacterMultiple(int x, int y) async {
  return await methodChannel.invokeMethod('setCharacterMultiple', {
    'x': x,
    'y': y,
  });
}

@override
Future<bool> setPrintModel(bool smallFont, bool isBold, bool isDoubleHeight, 
                         bool isDoubleWidth, bool isUnderLine) async {
  return await methodChannel.invokeMethod('setPrintModel', {
    'smallFont': smallFont,
    'isBold': isBold,
    'isDoubleHeight': isDoubleHeight,
    'isDoubleWidth': isDoubleWidth,
    'isUnderLine': isUnderLine,
  });
}

  
}