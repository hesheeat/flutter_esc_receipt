import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_usb_printer/flutter_usb_printer.dart';
import 'extension.dart';
import 'printer_controller.dart';

class USEDevice {
  String? name;
  String? manufacturer;
  int? vendorId;
  int? productId;
  int? deviceId;
  USEDevice({
    this.name,
    this.manufacturer,
    this.vendorId,
    this.productId,
    this.deviceId,
  });
}

class USEPrinterController extends PrinterController {
  static Future<List<USEDevice>> listUSEDevices() async {
    List<USEDevice> devices = [];
    if (Platform.isAndroid) {
      var results = await FlutterUsbPrinter.getUSBDeviceList();
      devices = [
        ...results
            .map((e) => USEDevice(
                  name: e["productName"],
                  manufacturer: e["manufacturer"],
                  vendorId: int.tryParse(e["vendorId"]),
                  productId: int.tryParse(e["productId"]),
                  deviceId: int.tryParse(e["deviceId"]),
                ))
            .toList()
      ];
    }
    return devices;
  }

  final usbPrinter = FlutterUsbPrinter();
  final USEDevice usbDevice;

  USEPrinterController({
    required this.usbDevice,
  });

  @override
  Future<void> connect({Duration? timeout}) async {
    if (Platform.isAndroid) {
      print(
          'connected use device: vendorId ${usbDevice.vendorId}, productId ${usbDevice.productId}');
      if (usbDevice.vendorId == null || usbDevice.productId == null) {
        throw Exception('invalid usb device vendorId or productId');
      }
      var result =
          await usbPrinter.connect(usbDevice.vendorId!, usbDevice.productId!);
      if (result == null) {
        throw Exception('failed to connect use device');
      }
    } else {
      throw Exception('unsupported platform');
    }
  }

  @override
  Future<void> close() async {
    if (Platform.isAndroid) {
      await usbPrinter.close();
    }
  }

  @override
  Future<void> write(List<int> data) async {
    if (Platform.isAndroid) {
      var bytes = Uint8List.fromList(data);
      int max = 16384;

      /// maxChunk limit on android
      var datas = bytes.chunkBy(max);
      await Future.forEach(
          datas, (dynamic data) async => await usbPrinter.write(data));
    }
  }
}
