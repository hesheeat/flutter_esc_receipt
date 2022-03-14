import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'network_analyzer.dart';
import 'printer_controller.dart';

class NetworkPrinterController extends PrinterController {
  static Future<List<NetworkAddress>> listNetworkDevices(
      {int port = 9100}) async {
    String? subnet = await NetworkAnalyzer.getSubmask();
    if (subnet == null) {
      String ip = (await NetworkAnalyzer.getAddresses()).first;
      subnet = ip.substring(0, ip.lastIndexOf('.'));
    }

    final stream = NetworkAnalyzer.discover2(subnet, port);
    var results = await stream.toList();
    return results.where((entry) => entry.exists).toList();
  }

  final NetworkAddress networkAddress;

  Socket? _socket;

  NetworkPrinterController({
    required this.networkAddress,
  });

  @override
  Future<void> connect({Duration? timeout}) async {
    _socket = await Socket.connect(networkAddress.ip, networkAddress.port,
        timeout: timeout);
  }

  @override
  Future<void> close() async {
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
  }

  @override
  Future<void> write(List<int> data) async {
    _socket?.add(data);
    await _socket?.flush();
  }
}
