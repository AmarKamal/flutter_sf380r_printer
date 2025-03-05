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
      case 'onDeviceDiscovered':
      if (_onDeviceDiscoveredCallback != null) {
        final Map<dynamic, dynamic> deviceMap = call.arguments;
        final device = BluetoothDevice.fromMap(deviceMap);
        _onDeviceDiscoveredCallback!(device);
      }
        break;
    case 'onScanFinished':
      if (_onScanFinishedCallback != null) {
        _onScanFinishedCallback!();
      }
        break;
    case 'onPairingStatus':
      if (_onPairingStatusCallback != null) {
        final String address = call.arguments['address'];
        final bool success = call.arguments['success'];
        _onPairingStatusCallback!(address, success);
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

  @override
  Future<bool> setEncoding(String encoding) async {
    return await methodChannel.invokeMethod('setEncoding', {
      'encoding': encoding,
    });
  }
  


Function(BluetoothDevice)? _onDeviceDiscoveredCallback;
Function()? _onScanFinishedCallback;
Function(String, bool)? _onPairingStatusCallback;

@override
Future<bool> startScan({Duration timeout = const Duration(seconds: 10)}) async {
  return await methodChannel.invokeMethod('startScan', {
    'timeout': timeout.inMilliseconds,
  });
}

@override
Future<bool> stopScan() async {
  return await methodChannel.invokeMethod('stopScan');
}

@override
Future<bool> pairDevice(String address) async {
  return await methodChannel.invokeMethod('pairDevice', {
    'address': address,
  });
}

@override
Future<bool> isDevicePaired(String address) async {
  return await methodChannel.invokeMethod('isDevicePaired', {
    'address': address,
  });
}

@override
void registerDeviceDiscoveredCallback(Function(BluetoothDevice) callback) {
  _onDeviceDiscoveredCallback = callback;
}

@override
void registerScanFinishedCallback(Function() callback) {
  _onScanFinishedCallback = callback;
}

@override
void registerPairingStatusCallback(Function(String, bool) callback) {
  _onPairingStatusCallback = callback;
}

}