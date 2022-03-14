import 'dart:io';
import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as themal;

import 'printer_controller.dart';

class BluetoothPrinterController extends PrinterController {
  static Future<List<themal.BluetoothDevice>> listBluetoothDevices() async {
    if (Platform.isAndroid || Platform.isIOS) {
      themal.BlueThermalPrinter bluetooth = themal.BlueThermalPrinter.instance;
      var results = await bluetooth.getBondedDevices();
      return results;
    }
    return [];
  }

  final themal.BluetoothDevice bluetoothDevice;

  BluetoothPrinterController({
    required this.bluetoothDevice,
  });

  @override
  Future<void> close() async {
    if (Platform.isAndroid || Platform.isIOS) {
      await themal.BlueThermalPrinter.instance.disconnect();
    }
  }

  @override
  Future<void> connect({Duration? timeout}) async {
    if (Platform.isAndroid || Platform.isIOS) {
      await themal.BlueThermalPrinter.instance.connect(bluetoothDevice);
    }
  }

  @override
  Future<void> write(List<int> data) async {
    if (Platform.isAndroid || Platform.isIOS) {
      Uint8List message = Uint8List.fromList(data);
      await themal.BlueThermalPrinter.instance.writeBytes(message);
    }
  }
}
