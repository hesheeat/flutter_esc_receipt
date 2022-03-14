import 'package:flutter/material.dart';
import 'package:flutter_esc_receipt/flutter_esc_receipt.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  @override
  _BluetoothPrinterScreenState createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  bool _isLoading = false;
  List<BluetoothDevice> _devices = [];
  BluetoothPrinterController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Printer Screen"),
      ),
      body: ListView(
          children: _devices
              .map((d) => ListTile(
                    title: Text("${d.name}"),
                    subtitle: Text("${d.address}"),
                    leading: const Icon(Icons.bluetooth),
                    onTap: () => _connect(d),
                    // onLongPress: () {
                    //   _startPrinter();
                    // },
                    //   selected: printer.connected,
                  ))
              .toList()),
      floatingActionButton: FloatingActionButton(
        child:
            _isLoading ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
        onPressed: _isLoading ? null : _scan,
      ),
    );
  }

  _scan() async {
    print("scan");
    setState(() {
      _isLoading = true;
      _devices = [];
    });
    var devices = await BluetoothPrinterController.listBluetoothDevices();
    print(devices);
    setState(() {
      _isLoading = false;
      _devices = devices;
    });
  }

  _connect(BluetoothDevice bluetoothDevice) async {
    var controller =
        BluetoothPrinterController(bluetoothDevice: bluetoothDevice);
    await controller.connect();
    print(" -==== connected =====- ");
    setState(() {
      _controller = controller;
    });
  }
}
