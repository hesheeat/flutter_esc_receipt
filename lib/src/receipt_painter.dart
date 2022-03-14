import 'printer_controller.dart';
import 'receipt_builder.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';

class ReceiptPainter {
  final PrinterController controller;
  ReceiptPainter({required this.controller});

  Future<ReceiptBuilder> builder(
      {CapabilityProfile? profile,
      PaperSize paperSize = PaperSize.mm80,
      int spaceBetweenRows = 5}) async {
    profile ??= await CapabilityProfile.load();

    return ReceiptBuilder(
        controller: controller,
        profile: profile,
        paperSize: paperSize,
        spaceBetweenRows: spaceBetweenRows);
  }
}
