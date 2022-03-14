import 'package:flutter/material.dart';
import 'package:flutter_esc_receipt/flutter_esc_receipt.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';

class NetworkPrinterScreen extends StatefulWidget {
  @override
  _NetworkPrinterScreenState createState() => _NetworkPrinterScreenState();
}

class _NetworkPrinterScreenState extends State<NetworkPrinterScreen> {
  bool _isLoading = false;
  List<String> _devices = [];
  NetworkPrinterController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Network Printer Screen"),
      ),
      body: ListView(
          children: _devices
              .map((d) => ListTile(
                    title: Text("$d"),
                    subtitle: Text("$d"),
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
    var devices = await NetworkPrinterController.listDevices();
    print(devices);
    setState(() {
      _isLoading = false;
      _devices = devices;
    });
  }

  _connect(String address, {int port = 9100}) async {
    var controller = NetworkPrinterController(
      address: address,
      port: port,
    );
    await controller.connect();
    print(" -==== connected =====- ");
    setState(() {
      _controller = controller;
    });
  }
}
