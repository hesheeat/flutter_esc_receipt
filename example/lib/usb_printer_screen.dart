import 'package:flutter/material.dart';
import 'package:flutter_esc_receipt/flutter_esc_receipt.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';

class USBPrinterScreen extends StatefulWidget {
  @override
  _USBPrinterScreenState createState() => _USBPrinterScreenState();
}

class _USBPrinterScreenState extends State<USBPrinterScreen> {
  bool _isLoading = false;
  List<USBDevice> _devices = [];
  USBPrinterController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("USB Printer Screen"),
      ),
      body: ListView(
          children: _devices
              .map((d) => ListTile(
                    title: Text("${d.name}"),
                    subtitle: Text("${d.manufacturer}"),
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
    var devices = await USBPrinterController.listDevices();
    print(devices);
    setState(() {
      _isLoading = false;
      _devices = devices;
    });
  }

  _connect(USBDevice usbDevice) async {
    var controller = USBPrinterController(usbDevice: usbDevice);
    await controller.connect();
    print(" -==== connected =====- ");
    setState(() {
      _controller = controller;
    });
  }
}
