
// ignore_for_file: unused_element


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sf380r_printer/flutter_sf380r_printer.dart';
import 'package:flutter_sf380r_printer_example/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _printer = FlutterSf380rPrinter();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  String _status = 'Ready';

//////////////////////////////////////////FOR CONNECTION //////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  // Updated initState method
  @override
  void initState() {
    super.initState();
    _setupPrinter();
    _checkPermissions();
  }

  // New method to check permissions
  Future<void> _checkPermissions() async {
    // Wait a moment for the UI to build before requesting permissions
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final permissionsGranted = await BluetoothPermissionHandler.requestBluetoothPermissions(context);
      if (permissionsGranted) {
        setState(() {
          _status = 'Ready to scan for devices';
        });
      } else {
        setState(() {
          _status = 'Bluetooth permissions not granted';
        });
      }
    });
  }

  // Updated _getDevices method with permission check
  Future<void> _getDevices() async {
    try {
      // Check permissions before scanning
      final permissionsGranted = await BluetoothPermissionHandler.requestBluetoothPermissions(context);
      if (!permissionsGranted) {
        setState(() {
          _status = 'Bluetooth permissions required';
        });
        return;
      }

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  Future<void> _testAllPrinterFeatures() async {
    try {
      setState(() {
        _status = 'Running comprehensive printer test...';
      });

      // Print a test header
      await _printer.printText("\n=== COMPREHENSIVE PRINTER TEST ===\n\n");

      
      // 1. Text Alignment Tests  
      await _printer.printText("1. ALIGNMENT TESTS\n",alignment : FlutterSf380rPrinter.ALIGN_CENTER,);  
      await _printer.printText("Centered Text\n",alignment : FlutterSf380rPrinter.ALIGN_CENTER);
      await _printer.printText("Left Aligned Text\n",alignment : FlutterSf380rPrinter.ALIGN_LEFT);  
      await _printer.printText("Right Aligned Text\n\n",alignment : FlutterSf380rPrinter.ALIGN_RIGHT);

      // 2. Text Formatting Tests
      await _printer.printText("2. TEXT FORMATTING\n");
      
      // Normal text      
      await _printer.printText("Normal Text\n");
      
      // Normal smallfont    
      await _printer.printText("Small Text\n",smallFont: true);
      
      // Bold text        
      await _printer.printText("Bold Text\n",bold: true);
      await _printer.printText("not Bold Text\n",bold: false);
        

      // Underlined text        
      await _printer.printText("Underlined Text\n",underline: true);
      
      // Bold and underlined        
      await _printer.printText("Bold & Underlined\n\n",underline: true,bold: true);

      
      //await _printer.setPrintModel(false, false, false, false, false);
      // 3. Text Size Tests
      await _printer.printText("3. TEXT SIZE\n");
      
      await _printer.printText("Normal Size\n");
      
      await _printer.printText("Double Width\n",doubleWidth: true);
      
      await _printer.printText("Double Height\n",doubleHeight: true);
      
      await _printer.printText("Double Width & Height\n\n" ,doubleHeight: true,doubleWidth: true);

      // 4. Barcode Test
      await _printer.printText("4. BARCODE TEST\n",alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      // Set center alignment before printing
      await _printer.printBarcode("1234567890",type: FlutterSf380rPrinter.BARCODE_CODE39,width: 5,height: 100,position: FlutterSf380rPrinter.POSITION_ABOVE,alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      await _printer.printBarcode("1234567890",type: FlutterSf380rPrinter.BARCODE_CODE39,width: 5,height: 100,position: FlutterSf380rPrinter.POSITION_ABOVE,alignment: FlutterSf380rPrinter.ALIGN_LEFT );
      await _printer.printBarcode("1234567890",type: FlutterSf380rPrinter.BARCODE_CODE39,width: 5,height: 100,position: FlutterSf380rPrinter.POSITION_ABOVE,alignment: FlutterSf380rPrinter.ALIGN_RIGHT);
      

      // 5. QR Code Test
      await _printer.printText("\n5. QR CODE TEST\n",alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      // Ensure center alignment    
      await _printer.printQRCode("https://example.com/test",moduleSize: 5,alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      await _printer.printQRCode("https://example.com/test",moduleSize: 5,alignment: FlutterSf380rPrinter.ALIGN_LEFT);
      await _printer.printQRCode("https://example.com/test",moduleSize: 5,alignment: FlutterSf380rPrinter.ALIGN_RIGHT);

      // 6. Image Test (if an image asset is available)
      await _printer.printText("\n6. IMAGE TEST\n",alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      try {
        // Ensure center alignment            
        final ByteData imageData = await rootBundle.load('assets/images/logo-twister-allBlack (2).png');
        final Uint8List imageBytes = imageData.buffer.asUint8List();
        await _printer.printImage(imageBytes,alignment: FlutterSf380rPrinter.ALIGN_RIGHT);
        await _printer.printImage(imageBytes,alignment: FlutterSf380rPrinter.ALIGN_CENTER);
        await _printer.printImage(imageBytes,alignment: FlutterSf380rPrinter.ALIGN_LEFT);
      } catch (e) {
        await _printer.printText("Image printing failed: $e\n");
      }

      // 7. Table Test
      await _printer.printText("\n7. TABLE TEST\n");
      List<String> columns = ["Item", "Qty", "Price"];
      List<int> columnWidths = [16, 6, 10];
      List<List<String>> rows = [
        ["Test Product", "2", "19.99"],
        ["Another Item", "1", "9.50"],
      ];
      await _printer.printTable(columns, columnWidths, rows);

      // 8. Encoding Test
      await _printer.printText("\n8. ENCODING TEST\n");
      await _printer.setEncoding("UTF-8");
      await _printer.printText("Special Characters: '\$€£¥₹\n");

      // 9. Receipt-like Output
      await _printer.printText("\n9. RECEIPT-LIKE OUTPUT\n");
      
      await _printer.printText("SAMPLE RECEIPT\n",alignment: FlutterSf380rPrinter.ALIGN_CENTER);
      
      await _printer.printText("Items:\n",alignment: FlutterSf380rPrinter.ALIGN_RIGHT);
      await _printer.printText("Total: RM 29.49\n",alignment: FlutterSf380rPrinter.ALIGN_RIGHT);    
      await _printer.printText("Thank You!\n",alignment: FlutterSf380rPrinter.ALIGN_CENTER);

      // // Final feed and reset
      await _printer.printText("\n\n\n\n");    

      setState(() {
        _status = 'Comprehensive printer test completed successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Comprehensive test failed: $e';
      });
      debugPrint('Comprehensive test error: $e');
    }
  }

  Future<void> _testAllPrinterFeatures1() async {
    try {
      setState(() {
        _status = 'Running comprehensive printer test...';
      });

      // Print a test header
      await _printer.printText("\n=== FORMATTING TEST ===\n\n");
      await Future.delayed(const Duration(milliseconds: 200)); // Add short delay between commands

      // 1. Text Formatting Tests - One at a time
      await _printer.printText("1. TEXT FORMATTING\n");
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Normal text      
      await _printer.printText("Normal Text\n");
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Small font text    
      await _printer.printText("Small Text\n", smallFont: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Bold text        
      await _printer.printText("Bold Text\n", bold: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Normal text after bold
      await _printer.printText("Not Bold Text\n", bold: false);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Underlined text        
      await _printer.printText("Underlined Text\n", underline: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Bold and underlined        
      await _printer.printText("Bold & Underlined\n", underline: true, bold: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Back to normal text
      await _printer.printText("Back to normal text\n");
      await Future.delayed(const Duration(milliseconds: 300));
      
      // 2. Size Tests
      await _printer.printText("\n2. SIZE TESTS\n");
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _printer.printText("Double Width\n", doubleWidth: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _printer.printText("Double Height\n", doubleHeight: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      await _printer.printText("Double Width & Height\n", doubleWidth: true, doubleHeight: true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Back to normal
      await _printer.printText("Back to normal size\n");
      
      // Final feed and reset
      await _printer.printText("\n\n\n\n");

      setState(() {
        _status = 'Formatting test completed successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Test failed: $e';
      });
      debugPrint('Test error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SF380R Printer Demo'),

        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: $_status', style: const TextStyle(fontWeight: FontWeight.bold)),
              //Text('image bytes: $_status', style: TextStyle(fontWeight: FontWeight.bold)),              
              
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
                     style: const TextStyle(fontWeight: FontWeight.bold)),
              
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
              
              if (_isConnected) ...[
                const Text('Print Options:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                Expanded(                  
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                       
                        ElevatedButton(
                          onPressed: _testAllPrinterFeatures1,
                          child: const Text('Test Advanced Formatting'),
                        ),
                        ElevatedButton(
                          onPressed: _testAllPrinterFeatures,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Print All', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}