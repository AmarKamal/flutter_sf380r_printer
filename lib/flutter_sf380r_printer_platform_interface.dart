import 'dart:async';
import 'dart:typed_data';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'flutter_sf380r_printer_method_channel.dart';

abstract class FlutterSf380rPrinterPlatform extends PlatformInterface {
  FlutterSf380rPrinterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSf380rPrinterPlatform _instance = MethodChannelFlutterSf380rPrinter();

  static FlutterSf380rPrinterPlatform get instance => _instance;

  static set instance(FlutterSf380rPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<BluetoothDevice>> getBluetoothDevices() {
    throw UnimplementedError('getBluetoothDevices() has not been implemented.');
  }

  Future<bool> connectBluetooth(String address) {
    throw UnimplementedError('connectBluetooth() has not been implemented.');
  }

  Future<bool> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }
  
  Future<bool> printText(
    String text, {
    int alignment = 0,
    bool bold = false,
    bool underline = false,
    bool doubleWidth = false,
    bool doubleHeight = false,
    bool smallFont = false,
  }) {
    throw UnimplementedError('printText() has not been implemented.');
  }

  Future<bool> printQRCode(
    String content, {
    int moduleSize = 4,
    int alignment = 0
  }) {
    throw UnimplementedError('printQRCode() has not been implemented.');
  }

  Future<bool> printBarcode(
    String content, {
    int type = 8,
    int width = 2,
    int height = 100,
    int position = 0,
    int alignment = 0,
  }) {
    throw UnimplementedError('printBarcode() has not been implemented.');
  }

  Future<bool> printImage(Uint8List imageBytes,{int alignment = 0}) {
    throw UnimplementedError('printImage() has not been implemented.');
  }

  Future<bool> printTable(
    List<String> columns,
    List<int> columnWidths,
    List<List<String>> rows,
  ) {
    throw UnimplementedError('printTable() has not been implemented.');
  }

  Future<int> getPrinterStatus() {
    throw UnimplementedError('getPrinterStatus() has not been implemented.');
  }

  Future<bool> setEncoding(String encoding) {
    throw UnimplementedError('setEncoding() has not been implemented.');
  }
  


  
  // Start scanning for Bluetooth devices
  Future<bool> startScan({Duration timeout = const Duration(seconds: 10)}) {
    throw UnimplementedError('startScan() has not been implemented.');
  }

  // Stop scanning for Bluetooth devices
  Future<bool> stopScan() {
    throw UnimplementedError('stopScan() has not been implemented.');
  }

  // Pair with a Bluetooth device
  Future<bool> pairDevice(String address) {
    throw UnimplementedError('pairDevice() has not been implemented.');
  }

  // Check if a device is paired
  Future<bool> isDevicePaired(String address) {
    throw UnimplementedError('isDevicePaired() has not been implemented.');
  }

  // Register callback for discovered devices
  void registerDeviceDiscoveredCallback(Function(BluetoothDevice) callback) {
    throw UnimplementedError('registerDeviceDiscoveredCallback() has not been implemented.');
  }

  // Register callback for scan finished
  void registerScanFinishedCallback(Function() callback) {
    throw UnimplementedError('registerScanFinishedCallback() has not been implemented.');
  }

  // Register callback for pairing status
  void registerPairingStatusCallback(Function(String, bool) callback) {
    throw UnimplementedError('registerPairingStatusCallback() has not been implemented.');
  }

  
  // Register event handlers
  void registerPrinterConnectedCallback(Function callback) {
    throw UnimplementedError('registerPrinterConnectedCallback() has not been implemented.');
  }

  void registerPrinterConnectionFailedCallback(Function callback) {
    throw UnimplementedError('registerPrinterConnectionFailedCallback() has not been implemented.');
  }

  void registerPrinterDisconnectedCallback(Function callback) {
    throw UnimplementedError('registerPrinterDisconnectedCallback() has not been implemented.');
  }



}

// Bluetooth device model
class BluetoothDevice {
  final String name;
  final String address;
  final int type;
  final bool isPrinter;

  BluetoothDevice({
    required this.name,
    required this.address,
    required this.type,
    required this.isPrinter,
  });

  factory BluetoothDevice.fromMap(Map<dynamic, dynamic> map) {
    return BluetoothDevice(
      name: map['name'] as String,
      address: map['address'] as String,
      type: map['type'] as int,
      isPrinter: map['isPrinter'] as bool,
    );
  }

  @override
  String toString() {
    return 'BluetoothDevice{name: $name, address: $address, type: $type, isPrinter: $isPrinter}';
  }
}