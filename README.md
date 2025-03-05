# Flutter SF380R Printer

A Flutter plugin for connecting to and printing with SF380R and compatible thermal printers over Bluetooth on Android. This package provides a comprehensive set of features for thermal receipt printing needs.

## Features

- Bluetooth device scanning and discovery (including unpaired devices)
- Bluetooth device pairing capability
- Bluetooth printer connection management
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
      url: https://github.com/AmarKamal/flutter_sf380r_printer.git 
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
      // New callbacks for scanning and pairing
      onDiscovered: (BluetoothDevice device) {
        setState(() {
          // Handle newly discovered device
        });
      },
      onScanComplete: () {
        setState(() {
          // Handle scan completion
        });
      },
      onPaired: (String address, bool success) {
        setState(() {
          // Handle pairing result
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
    _startScan();
  } else {
    // Show a dialog explaining why permissions are needed
  }
}
```

### Scan for Bluetooth Devices (Including Unpaired Devices)

```dart
// Get only paired devices (old method)
Future<void> _getPairedDevices() async {
  try {
    final devices = await _printer.getBluetoothDevices();
    setState(() {
      _devices = devices;
    });
  } catch (e) {
    print('Error getting paired devices: $e');
  }
}

// Scan for all available devices (new method)
Future<void> _startScan() async {
  try {
    setState(() {
      _isScanning = true;
      _devices = []; // Clear existing devices
    });
    
    // Start scanning with a 10-second timeout
    // Devices will be delivered via the onDiscovered callback
    await _printer.startScan(timeout: const Duration(seconds: 10));
  } catch (e) {
    setState(() {
      _isScanning = false;
    });
    print('Error scanning for devices: $e');
  }
}

// Stop an ongoing scan
Future<void> _stopScan() async {
  if (_isScanning) {
    await _printer.stopScan();
    setState(() {
      _isScanning = false;
    });
  }
}
```

### Pair with a Bluetooth Device

```dart
Future<void> _pairDevice(String address) async {
  try {
    // First check if already paired
    final isPaired = await _printer.isDevicePaired(address);
    
    if (isPaired) {
      print('Device is already paired');
      return;
    }
    
    // Initiate pairing - result will be delivered via onPaired callback
    await _printer.pairDevice(address);
  } catch (e) {
    print('Error pairing device: $e');
  }
}

// Check if a device is paired
Future<bool> _checkPairingStatus(String address) async {
  return await _printer.isDevicePaired(address);
}
```

### Connect to a Printer

```dart
Future<void> _connect(BluetoothDevice device) async {
  try {
    // Check if device is paired first
    final isPaired = await _printer.isDevicePaired(device.address);
    
    if (!isPaired) {
      // Pair the device first
      await _pairDevice(device.address);
      
      // Wait a moment for pairing to complete
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Now connect to the device
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

Here's a complete example that includes device scanning, pairing, and connection:

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
  bool _isScanning = false;
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
      onDiscovered: (BluetoothDevice device) {
        setState(() {
          if (!_devices.any((d) => d.address == device.address)) {
            _devices.add(device);
            _status = 'Found ${_devices.length} devices';
          }
        });
      },
      onScanComplete: () {
        setState(() {
          _isScanning = false;
          _status = 'Scan completed, found ${_devices.length} devices';
        });
      },
      onPaired: (String address, bool success) {
        setState(() {
          if (success) {
            _status = 'Device paired successfully';
          } else {
            _status = 'Pairing failed';
          }
        });
      },
    );
  }

  Future<void> _startScan() async {
    try {
      // Check permissions before scanning
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
      
      if (!permissionsGranted) {
        setState(() {
          _status = 'Bluetooth permissions required';
        });
        return;
      }

      setState(() {
        _status = 'Scanning for devices...';
        _isScanning = true;
        _devices = []; // Clear previous devices
      });

      // Start scanning with a timeout of 10 seconds
      await _printer.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      setState(() {
        _isScanning = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _stopScan() async {
    if (_isScanning) {
      try {
        await _printer.stopScan();
        setState(() {
          _isScanning = false;
          _status = 'Scan stopped, found ${_devices.length} devices';
        });
      } catch (e) {
        setState(() {
          _status = 'Error stopping scan: $e';
        });
      }
    }
  }

  Future<void> _pairDevice() async {
    if (_selectedDevice == null) return;

    try {
      setState(() {
        _status = 'Pairing with ${_selectedDevice!.name}...';
      });

      // Check if already paired
      final isPaired = await _printer.isDevicePaired(_selectedDevice!.address);
      
      if (isPaired) {
        setState(() {
          _status = 'Device is already paired';
        });
        return;
      }

      // Initiate pairing
      await _printer.pairDevice(_selectedDevice!.address);
      
      // Result will be handled by the onPaired callback
    } catch (e) {
      setState(() {
        _status = 'Error pairing: $e';
      });
    }
  }

  Future<void> _connect() async {
    if (_selectedDevice == null) return;
    
    try {
      setState(() {
        _status = 'Connecting...';
      });

      // First check if the device is paired
      final isPaired = await _printer.isDevicePaired(_selectedDevice!.address);
      
      if (!isPaired) {
        // Show a dialog to prompt for pairing
        final shouldPair = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pairing Required'),
            content: Text('Device ${_selectedDevice!.name} is not paired. Pair now?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Pair'),
              ),
            ],
          ),
        ) ?? false;

        if (shouldPair) {
          await _pairDevice();
          
          // Wait a moment after pairing before connecting
          await Future.delayed(const Duration(seconds: 1));
        } else {
          setState(() {
            _status = 'Connection canceled - device not paired';
          });
          return;
        }
      }

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
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isScanning ? null : _startScan,
                      child: Text(_isScanning ? 'Scanning...' : 'Search for Printers'),
                    ),
                  ),
                  if (_isScanning) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _stopScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Stop Scan', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ],
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
                      trailing: FutureBuilder<bool>(
                        future: _printer.isDevicePaired(device.address),
                        builder: (context, snapshot) {
                          final isPaired = snapshot.data ?? false;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(device.isPrinter ? 'Printer' : 'Device'),
                              const SizedBox(width: 8),
                              Icon(
                                isPaired ? Icons.link : Icons.link_off,
                                color: isPaired ? Colors.green : Colors.grey,
                              ),
                            ],
                          );
                        },
                      ),
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
              
              if (_selectedDevice != null) ...[
                Text('Selected: ${_selectedDevice!.name}', 
                     style: const TextStyle(fontWeight: FontWeight.bold)),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _isConnected ? null : _pairDevice,
                      child: const Text('Pair Device'),
                    ),
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
              ],
              
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

3. **Pairing Issues**
   - Some devices require a PIN code for pairing. The default PIN for many thermal printers is '0000' or '1234'.
   - If pairing fails, try power cycling the printer and trying again.
   - Ensure the printer is in pairing mode (many printers indicate this with a flashing LED).

4. **Connection Fails**
   - Verify the printer is charged or plugged in.
   - Try restarting the printer.
   - Make sure no other devices are currently connected to the printer.
   - Ensure you've paired with the device before trying to connect.

5. **Scan Not Finding Devices**
   - Check that location services are enabled (required for Bluetooth scanning on Android).
   - Ensure the printer is in discovery mode.
   - Some devices may only be discoverable for a limited time after entering discovery mode.

6. **Formatting Issues**
   - Different printer models may support different formatting features. Test basic printing first, then add formatting.
   - Some printers require a delay between commands for proper formatting.

7. **Images Not Printing Correctly**
   - Make sure the image is not too large (keep under 384px width for most thermal printers).
   - Try to use simple black and white images for best results.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Developed by [Amar Kamal]