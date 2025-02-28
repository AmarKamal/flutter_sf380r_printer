# Flutter SF380R Printer

A Flutter plugin for connecting to and printing with SF380R and compatible thermal printers over Bluetooth on Android. This package provides a comprehensive set of features for thermal receipt printing needs.

## Features

- Bluetooth device scanning and connection
- Text printing with formatting options (bold, underline, font size, alignment)
- QR Code and Barcode printing with customizable settings
- Image printing
- Table printing for receipt layouts
- Paper feed and printer status checking

## Installation

Add this package to your Flutter project by adding the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_sf380r_printer:
    git:
      url: https://github.com/yourusername/flutter_sf380r_printer.git
      ref: main
```

Or if you're using a specific version:

```yaml
dependencies:
  flutter_sf380r_printer: ^1.0.0
```

## Android Setup

Add the following permissions to your `AndroidManifest.xml` file:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

For Android 12 (API level 31) and above, the `BLUETOOTH_CONNECT` and `BLUETOOTH_SCAN` permissions must be explicitly requested at runtime.

## Usage

### Initialize the Printer

Create an instance of the printer in your widget:

```dart
import 'package:flutter_sf380r_printer/flutter_sf380r_printer.dart';

class _MyAppState extends State<MyApp> {
  final _printer = FlutterSf380rPrinter();
  
  @override
  void initState() {
    super.initState();
    _setupPrinter();
  }

  void _setupPrinter() {
    _printer.setCallbacks(
      onConnected: () {
        setState(() {
          // Handle connection success
        });
      },
      onConnectionFailed: () {
        setState(() {
          // Handle connection failure
        });
      },
      onDisconnected: () {
        setState(() {
          // Handle disconnection
        });
      },
    );
  }
}
```

### Request Permissions (Android)

For Android 12+, request the necessary permissions before scanning for devices:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> _checkPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.bluetooth,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
    Permission.location,
  ].request();
  
  bool allGranted = !statuses.values.any(
    (status) => status.isDenied || status.isPermanentlyDenied
  );
  
  if (allGranted) {
    // Permissions granted, proceed with scanning
    _getDevices();
  } else {
    // Show a dialog explaining why permissions are needed
  }
}
```

### Scan for Bluetooth Devices

```dart
Future<void> _getDevices() async {
  try {
    final devices = await _printer.getBluetoothDevices();
    setState(() {
      _devices = devices;
    });
  } catch (e) {
    print('Error scanning for devices: $e');
  }
}
```

### Connect to a Printer

```dart
Future<void> _connect(BluetoothDevice device) async {
  try {
    final connected = await _printer.connectBluetooth(device.address);
    setState(() {
      _isConnected = connected;
    });
  } catch (e) {
    print('Error connecting to printer: $e');
  }
}
```

### Print Text with Formatting

```dart
// Basic text printing
await _printer.printText("Hello, World!");

// Text with formatting
await _printer.printText(
  "This text is centered, bold, and underlined",
  alignment: FlutterSf380rPrinter.ALIGN_CENTER,
  bold: true,
  underline: true,
);

// Different text sizes
await _printer.printText(
  "Double height text",
  doubleHeight: true,
);

await _printer.printText(
  "Double width text",
  doubleWidth: true,
);

// Small font
await _printer.printText(
  "Small font text",
  smallFont: true,
);
```

### Print QR Codes

```dart
await _printer.printQRCode(
  "https://example.com",
  moduleSize: 7,  // QR code size (1-16)
  height: 200,
  position: FlutterSf380rPrinter.POSITION_BELOW,
  alignment: FlutterSf380rPrinter.ALIGN_CENTER, // Center the QR code
);
```

### Print Barcodes

```dart
await _printer.printBarcode(
  "1234567890",
  type: FlutterSf380rPrinter.BARCODE_CODE39,
  width: 2,
  height: 100,
  position: FlutterSf380rPrinter.POSITION_BELOW,
  alignment: FlutterSf380rPrinter.ALIGN_CENTER, // Center the barcode
);
```

### Print Images

```dart
import 'dart:typed_data';
import 'package:flutter/services.dart';

// Load an image from assets
final ByteData imageData = await rootBundle.load('assets/images/logo.png');
final Uint8List imageBytes = imageData.buffer.asUint8List();

// Print the image
await _printer.printImage(
  imageBytes,
  alignment: FlutterSf380rPrinter.ALIGN_CENTER, // Center the image
);
```

### Print Tables

```dart
// Define columns and their widths
List<String> columns = ['Item', 'Qty', 'Price'];
List<int> columnWidths = [16, 6, 8];

// Define rows
List<List<String>> rows = [
  ['Product 1', '2', '10.99'],
  ['Product 2', '1', '24.50'],
  ['Product 3', '3', '5.25'],
];

// Print the table
await _printer.printTable(columns, columnWidths, rows);
```

### Print a Complete Receipt

```dart
await _printer.printReceipt(
  header: "EXAMPLE STORE\n123 Main Street\nCity, State 12345",
  items: [
    {'name': 'Product 1', 'quantity': 2, 'price': 10.99},
    {'name': 'Product 2', 'quantity': 1, 'price': 24.50},
    {'name': 'Product 3', 'quantity': 3, 'price': 5.25},
  ],
  total: 56.24,
  footer: "Thank you for your purchase!",
  qrData: "https://example.com/receipt/12345",
);
```

### Disconnect

```dart
await _printer.disconnect();
```

## Constants

### Alignment
- `FlutterSf380rPrinter.ALIGN_LEFT` - Left alignment (default)
- `FlutterSf380rPrinter.ALIGN_CENTER` - Center alignment
- `FlutterSf380rPrinter.ALIGN_RIGHT` - Right alignment

### Barcode Types
- `FlutterSf380rPrinter.BARCODE_UPC_A`
- `FlutterSf380rPrinter.BARCODE_UPC_E`
- `FlutterSf380rPrinter.BARCODE_JAN13`
- `FlutterSf380rPrinter.BARCODE_JAN8`
- `FlutterSf380rPrinter.BARCODE_CODE39`
- `FlutterSf380rPrinter.BARCODE_ITF`
- `FlutterSf380rPrinter.BARCODE_CODABAR`
- `FlutterSf380rPrinter.BARCODE_CODE93`
- `FlutterSf380rPrinter.BARCODE_CODE128` (default)

### Text Position
- `FlutterSf380rPrinter.POSITION_NONE` - No text
- `FlutterSf380rPrinter.POSITION_ABOVE` - Text above barcode/QR
- `FlutterSf380rPrinter.POSITION_BELOW` - Text below barcode/QR
- `FlutterSf380rPrinter.POSITION_BOTH` - Text above and below

### Printer Status
- `FlutterSf380rPrinter.STATUS_READY` - Printer is ready
- `FlutterSf380rPrinter.STATUS_OUT_OF_PAPER` - Printer is out of paper
- `FlutterSf380rPrinter.STATUS_OPEN_LID` - Printer lid is open
- `FlutterSf380rPrinter.STATUS_ERROR` - Printer error

## Example App

```dart
import 'package:flutter/material.dart';
import 'package:flutter_sf380r_printer/flutter_sf380r_printer.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _printer = FlutterSf380rPrinter();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  String _status = 'Ready';
  
  @override
  void initState() {
    super.initState();
    _setupPrinter();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionsGranted = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ].request().then(
      (value) => !value.values.any(
        (status) => status.isDenied || status.isPermanentlyDenied
      )
    );
    
    setState(() {
      _status = permissionsGranted 
          ? 'Ready to scan for devices' 
          : 'Bluetooth permissions not granted';
    });
  }

  void _setupPrinter() {
    _printer.setCallbacks(
      onConnected: () {
        setState(() {
          _isConnected = true;
          _status = 'Printer connected';
        });
      },
      onConnectionFailed: () {
        setState(() {
          _isConnected = false;
          _status = 'Connection failed';
        });
      },
      onDisconnected: () {
        setState(() {
          _isConnected = false;
          _status = 'Printer disconnected';
        });
      },
    );
  }

  Future<void> _getDevices() async {
    try {
      setState(() {
        _status = 'Scanning for devices...';
      });
      final devices = await _printer.getBluetoothDevices();
      setState(() {
        _devices = devices;
        _status = 'Found ${devices.length} devices';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _connect() async {
    if (_selectedDevice == null) return;
    
    try {
      setState(() {
        _status = 'Connecting...';
      });
      final connected = await _printer.connectBluetooth(_selectedDevice!.address);
      if (!connected) {
        setState(() {
          _status = 'Failed to connect';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _disconnect() async {
    try {
      await _printer.disconnect();
      setState(() {
        _status = 'Disconnected';
        _isConnected = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error disconnecting: $e';
      });
    }
  }

  Future<void> _printSampleReceipt() async {
    try {
      await _printer.printText("\nSAMPLE RECEIPT\n", 
                            alignment: FlutterSf380rPrinter.ALIGN_CENTER,
                            bold: true);
      await _printer.printText("123 Main Street\nCity, State 12345\n\n");
      
      // Print items table
      List<String> columns = ['Item', 'Qty', 'Price'];
      List<int> columnWidths = [16, 6, 8];
      List<List<String>> rows = [
        ['Product 1', '2', '10.99'],
        ['Product 2', '1', '24.50'],
        ['Product 3', '3', '5.25'],
      ];
      
      await _printer.printTable(columns, columnWidths, rows);
      
      await _printer.printText("\nTotal: $56.24\n\n");
      await _printer.printText("Thank you for your purchase!\n\n");
      
      await _printer.printQRCode("https://example.com/receipt/12345",
                               alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      
      await _printer.printText("\n\n\n\n");
      
      setState(() {
        _status = 'Receipt printed successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Print error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SF380R Printer Demo'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $_status', style: TextStyle(fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 16),
              
              ElevatedButton(
                onPressed: _getDevices,
                child: const Text('Search for Printers'),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: _devices.length,
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    return ListTile(
                      title: Text(device.name),
                      subtitle: Text(device.address),
                      trailing: Text(device.isPrinter ? 'Printer' : 'Device'),
                      selected: _selectedDevice?.address == device.address,
                      onTap: () {
                        setState(() {
                          _selectedDevice = device;
                        });
                      },
                    );
                  },
                ),
              ),
              
              if (_selectedDevice != null)
                Text('Selected: ${_selectedDevice!.name}', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _isConnected ? null : _connect,
                    child: const Text('Connect'),
                  ),
                  ElevatedButton(
                    onPressed: _isConnected ? _disconnect : null,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              if (_isConnected)
                ElevatedButton(
                  onPressed: _printSampleReceipt,
                  child: const Text('Print Sample Receipt'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   - Make sure you've added all necessary permissions to your Android manifest and requested runtime permissions for Android 12+.

2. **Device Not Found**
   - Ensure Bluetooth is enabled on your device.
   - Check if the printer is powered on and in discovery mode.

3. **Connection Fails**
   - Verify the printer is charged or plugged in.
   - Try restarting the printer.
   - Make sure no other devices are currently connected to the printer.

4. **Formatting Issues**
   - Different printer models may support different formatting features. Test basic printing first, then add formatting.
   - Some printers require a delay between commands for proper formatting.

5. **Images Not Printing Correctly**
   - Make sure the image is not too large (keep under 384px width for most thermal printers).
   - Try to use simple black and white images for best results.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Developed by [Amar Kamal]