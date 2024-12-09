import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:provider/provider.dart'; // For accessing HealthData
import 'health_data.dart'; // Import your HealthData provider

class BluetoothSyncButton extends StatefulWidget {
  final String esp32DeviceName;
  final void Function(String data)? onDataReceived;

  const BluetoothSyncButton({
    Key? key,
    required this.esp32DeviceName,
    this.onDataReceived,
  }) : super(key: key);

  @override
  _BluetoothSyncButtonState createState() => _BluetoothSyncButtonState();
}

class _BluetoothSyncButtonState extends State<BluetoothSyncButton> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? notifyCharacteristic;
  StreamSubscription? scanSubscription;
  StreamSubscription<BluetoothConnectionState>? deviceConnectionSubscription;
  StreamSubscription<List<int>>? notifySubscription;

  bool isScanning = false;
  bool isConnecting = false;
  bool isReceivingData = false;

  final List<int> buffer = [];
  final int triggerByte = 0x7E; // Adjust per your device protocol
  final int dataLength = 5;   // Adjust to your known packet length

  @override
  void dispose() {
    _disconnectFromDevice();
    scanSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses.values.any((status) => status.isDenied || status.isPermanentlyDenied)) {
      _showPermissionDeniedDialog();
      return;
    }
  }

  Future<void> _startScan() async {
    await _requestPermissions();

    if (isScanning || isConnecting || isReceivingData) return;

    setState(() {
      isScanning = true;
    });

    try {
      // Start scanning
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));

      scanSubscription = FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult scanResult in results) {
          if (scanResult.device.name == widget.esp32DeviceName) {
            // Device found, stop scanning and connect
            await FlutterBluePlus.stopScan();
            scanSubscription?.cancel();
            _connectToDevice(scanResult.device);
            return;
          }
        }
      });

      // Wait for scan to complete
      await Future.delayed(const Duration(seconds: 3));

      // After timeout, check if still scanning
      if (isScanning) {
        await FlutterBluePlus.stopScan();
        scanSubscription?.cancel();
        setState(() {
          isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device not found'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Scan error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan error: $e')),
      );
    } finally {
      // Ensure scanning is stopped
      if (isScanning) {
        await FlutterBluePlus.stopScan();
        scanSubscription?.cancel();
        setState(() {
          isScanning = false;
        });
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    setState(() {
      isConnecting = true;
      isScanning = false;
    });

    try {
      await device.connect();
      connectedDevice = device;

      deviceConnectionSubscription = device.state.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _disconnectFromDevice();
        }
      });

      await _discoverServices(device);
    } catch (e) {
      _disconnectFromDevice();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error connecting to device: $e')),
      );
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> _discoverServices(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            notifyCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);

            notifySubscription = characteristic.value.listen((value) {
              _onDataReceived(value);
            });

            setState(() {
              isReceivingData = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected to device'),
                duration: Duration(seconds: 1),
              ),
            );
            return; // Found a suitable characteristic
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No suitable characteristic found')),
      );
      _disconnectFromDevice();
    } catch (e) {
      debugPrint('Service discovery error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service discovery error: $e')),
      );
      _disconnectFromDevice();
    }
  }

  void _onDataReceived(List<int> data) {
    buffer.addAll(data);

    // Process buffer for a complete packet
    while (buffer.length >= dataLength) {
      int triggerIndex = buffer.indexOf(triggerByte);
      if (triggerIndex != -1 && (buffer.length - triggerIndex) >= dataLength) {
        List<int> packet = buffer.sublist(triggerIndex, triggerIndex + dataLength);

        // Process the packet:
        // Assuming format: [0x7E, heartRate, spO2, glucose, cholesterol, ...]
        // Adjust parsing logic as per your protocol
        double heartRateVal = 0.0;
        double spO2Val = 0.0;
        double glucoseVal = 0.0;
        double cholesterolVal = 0.0;

        // Example parsing (just for demonstration):
        // Skip the trigger byte at packet[0]
        // Convert following bytes to values. This is simplistic and depends on your data format.
        if (packet.length >= 5) {
          heartRateVal = packet[1].toDouble();
          spO2Val = packet[2].toDouble();
          glucoseVal = packet[3].toDouble();
          cholesterolVal = packet[4].toDouble();
        }

        // Call the callback if needed
        String dataString = packet.toString();
        widget.onDataReceived?.call(dataString);

        // Integrate with HealthData provider to upload to Firebase
        final healthData = Provider.of<HealthData>(context, listen: false);
        DateTime now = DateTime.now();
        
        // Add data to Firestore via HealthData. This ensures offline/online sync automatically.
        healthData.addHeartRate(now, heartRateVal);
        healthData.addSpO2Level(now, spO2Val);
        healthData.addGlucoseLevel(now, glucoseVal);
        healthData.addCholesterolLevel(now, cholesterolVal);

        debugPrint('Data parsed and uploaded: HR=$heartRateVal, SpO2=$spO2Val, Glucose=$glucoseVal, Cholesterol=$cholesterolVal');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data sync successful!'),
            duration: Duration(seconds: 1),
          ),
        );

        // Remove processed bytes
        buffer.removeRange(0, triggerIndex + dataLength);

        // Optionally disconnect after receiving one packet:
        _disconnectFromDevice();

        break;
      } else {
        // If we haven't found a complete packet, adjust buffer
        if (triggerIndex != -1) {
          buffer.removeRange(0, triggerIndex);
        } else {
          if (buffer.length > dataLength - 1) {
            buffer.removeRange(0, buffer.length - (dataLength - 1));
          }
          break;
        }
      }
    }
  }

  Future<void> _disconnectFromDevice() async {
    await notifySubscription?.cancel();
    await deviceConnectionSubscription?.cancel();
    if (connectedDevice != null) {
      try {
        await connectedDevice!.disconnect();
      } catch (e) {
        // Ignore disconnect errors
      }
    }
    setState(() {
      connectedDevice = null;
      notifyCharacteristic = null;
      isReceivingData = false;
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
            'Bluetooth and location permissions are required to use this feature.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isBusy = isScanning || isConnecting || isReceivingData;
    String buttonText = isScanning
        ? 'Scanning...'
        : isConnecting
            ? 'Connecting...'
            : isReceivingData
                ? 'Receiving...'
                : 'Sync Bluetooth';

    return ElevatedButton(
      onPressed: isBusy ? null : _startScan,
      style: ElevatedButton.styleFrom(
        backgroundColor: isBusy ? const Color.fromARGB(255, 48, 0, 61) : const Color.fromARGB(255, 219, 50, 205),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 28.0),
        textStyle: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: isBusy ? 0 : 8,
        shadowColor: Colors.purple.shade200.withOpacity(0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isBusy)
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
          Text(buttonText),
        ],
      ),
    );
  }
}