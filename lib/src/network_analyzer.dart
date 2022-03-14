import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

/*
 * ping_discover_network
 * Created by Andrey Ushakov
 * 
 * See LICENSE for distribution and usage details.
 */

/// [NetworkAnalyzer] class returns instances of [NetworkAddress].
///
/// Found ip addresses will have [exists] == true field.
// class NetworkAddress {
//   final String ip;
//   final int port;
//   final bool exists;
//   NetworkAddress(this.ip, this.port, this.exists);
// }

/// Pings a given subnet (xxx.xxx.xxx) on a given port using [discover] method.
class NetworkAnalyzer {
  static Future<String?> getSubmask() async {
    final info = NetworkInfo();
    var submask = await info.getWifiSubmask();
    return submask;
  }

  static Future<List<String>> getAddresses() async {
    var interfaces = await NetworkInterface.list();
    List<String> results = [];
    interfaces.fold(
        results,
        (dynamic pre, e) =>
            results.addAll(e.addresses.map((e) => e.address).toList()));
    return results;
  }

  /// Pings a given [subnet] (xxx.xxx.xxx) on a given [port].
  ///
  /// Pings IP:PORT one by one
  static Stream<String> discover(
    String subnet,
    int port, {
    Duration timeout = const Duration(milliseconds: 400),
  }) async* {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }

    for (int i = 1; i < 256; ++i) {
      final host = '$subnet.$i';

      try {
        final Socket s = await Socket.connect(host, port, timeout: timeout);
        s.destroy();
        yield host;
      } catch (e) {
        if (e is! SocketException) {
          rethrow;
        }

        // Check if connection timed out or we got one of predefined errors
        // if (e.osError == null || _errorCodes.contains(e.osError?.errorCode)) {
        //   yield NetworkAddress(host, port, false);
        // } else {
        //   // Error 23,24: Too many open files in system
        //   rethrow;
        // }
      }
    }
  }

  /// Pings a given [subnet] (xxx.xxx.xxx) on a given [port].
  ///
  /// Pings IP:PORT all at once
  static Stream<String> discover2(
    String subnet,
    int port, {
    int firstSubnet = 1,
    int lastSubnet = 254,
    Duration timeout = const Duration(seconds: 5),
  }) {
    if (port < 1 || port > 65535) {
      throw 'Incorrect port';
    }

    final int maxEnd = getMaxHost(subnet);
    if (firstSubnet > lastSubnet ||
        firstSubnet < 1 ||
        lastSubnet < 1 ||
        firstSubnet > maxEnd ||
        lastSubnet > maxEnd) {
      throw 'Invalid subnet range or firstSubnet < lastSubnet is not true';
    }
    final int lastValidSubnet = min(lastSubnet, maxEnd);

    final out = StreamController<String>();
    final futures = <Future<Socket>>[];
    for (int i = firstSubnet; i <= lastValidSubnet; i++) {
      final host = '$subnet.$i';
      final Future<Socket> f = _ping(host, port, timeout);
      futures.add(f);
      f.then((socket) {
        socket.destroy();
        out.sink.add(host);
      }).catchError((dynamic e) {
        if (e is! SocketException) {
          throw e;
        }

        // Check if connection timed out or we got one of predefined errors
        // if (e.osError == null || _errorCodes.contains(e.osError?.errorCode)) {
        //   out.sink.add(NetworkAddress(host, port, false));
        // } else {
        //   // Error 23,24: Too many open files in system
        //   throw e;
        // }
      });
    }

    Future.wait<Socket>(futures)
        .then<void>((sockets) => out.close())
        .catchError((dynamic e) => out.close());

    return out.stream;
  }

  static Future<Socket> _ping(String host, int port, Duration timeout) {
    return Socket.connect(host, port, timeout: timeout).then((socket) {
      return socket;
    });
  }

  static int getMaxHost(String subnet) {
    final List<String> lastSubnetStr = subnet.split('.');
    if (lastSubnetStr.isEmpty) {
      throw 'Invalid subnet Address';
    }

    final int lastSubnet = int.parse(lastSubnetStr[0]);

    if (lastSubnet < 128) {
      return 16777216;
    } else if (lastSubnet >= 128 && lastSubnet < 192) {
      return 65536;
    } else if (lastSubnet >= 192 && lastSubnet < 224) {
      return 256;
    }
    return 256;
  }

  // 13: Connection failed (OS Error: Permission denied)
  // 49: Bind failed (OS Error: Can't assign requested address)
  // 61: OS Error: Connection refused
  // 64: Connection failed (OS Error: Host is down)
  // 65: No route to host
  // 101: Network is unreachable
  // 111: Connection refused
  // 113: No route to host
  // <empty>: SocketException: Connection timed out
  static final _errorCodes = [13, 49, 61, 64, 65, 101, 111, 113];
}
