import 'package:flutter/material.dart';
import 'package:flutter_sf380r_printer/flutter_sf380r_printer.dart';
import 'package:permission_handler/permission_handler.dart';


class BluetoothPermissionHandler {
  /// Request all required Bluetooth permissions based on device Android version
  static Future<bool> requestBluetoothPermissions(BuildContext context) async {
    // Check if permissions are already granted
    bool allGranted = await _checkPermissions();
    if (allGranted) return true;
    
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location, // Often required for Bluetooth scanning to work
    ].request();
    
    // Check if all permissions were granted
    bool anyDenied = statuses.values.any(
      (status) => status.isDenied || status.isPermanentlyDenied
    );
    
    if (anyDenied) {
      // ignore: use_build_context_synchronously
      _showPermissionDeniedDialog(context);
      return false;
    }
    
    return true;
  }
  
  /// Check if all required Bluetooth permissions are granted
  static Future<bool> _checkPermissions() async {
    bool bluetoothPermission = await Permission.bluetooth.isGranted;
    bool bluetoothConnectPermission = true; // Default to true for older Android versions
    bool bluetoothScanPermission = true; // Default to true for older Android versions
    bool locationPermission = await Permission.location.isGranted;
    
    // Check for Android 12+ specific permissions
    if (int.parse(await _getPlatformVersion()) >= 31) {
      bluetoothConnectPermission = await Permission.bluetoothConnect.isGranted;
      bluetoothScanPermission = await Permission.bluetoothScan.isGranted;
    }
    
    return bluetoothPermission && bluetoothConnectPermission && bluetoothScanPermission && locationPermission;
  }
  
  /// Helper method to get Android SDK version
  static Future<String> _getPlatformVersion() async {
    try {
      // Use Platform.version to get Android SDK version
      final String platformVersion = await FlutterSf380rPrinter().getPlatformVersion() ?? "0";
      // Extract SDK version from platformVersion string which is in format "Android X.Y.Z"
      final RegExp regex = RegExp(r'Android (\d+)');
      final match = regex.firstMatch(platformVersion);
      return match?.group(1) ?? "0";
    } catch (e) {
      return "0"; // Return 0 if there's an error
    }
  }
  
  /// Show a dialog when permissions are denied
  static void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bluetooth Permissions Required'),
          content: const Text(
            'This app needs Bluetooth permissions to connect to the printer. '
            'Please grant these permissions in the app settings.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}