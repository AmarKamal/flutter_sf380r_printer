// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_sf380r_printer/flutter_sf380r_printer.dart';
// import 'package:flutter_sf380r_printer/flutter_sf380r_printer_platform_interface.dart';
// import 'package:flutter_sf380r_printer/flutter_sf380r_printer_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterSf380rPrinterPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterSf380rPrinterPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterSf380rPrinterPlatform initialPlatform = FlutterSf380rPrinterPlatform.instance;

//   test('$MethodChannelFlutterSf380rPrinter is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterSf380rPrinter>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterSf380rPrinter flutterSf380rPrinterPlugin = FlutterSf380rPrinter();
//     MockFlutterSf380rPrinterPlatform fakePlatform = MockFlutterSf380rPrinterPlatform();
//     FlutterSf380rPrinterPlatform.instance = fakePlatform;

//     expect(await flutterSf380rPrinterPlugin.getPlatformVersion(), '42');
//   });
// }
