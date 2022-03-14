import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:image/image.dart' as img;

import 'printer_controller.dart';

class ReceiptBuilder {
  final PrinterController controller;
  final Generator generator;

  final List<int> payload = [];

  ReceiptBuilder({
    required this.controller,
    required CapabilityProfile profile,
    PaperSize paperSize = PaperSize.mm80,
    int spaceBetweenRows = 5,
  }) : generator =
            Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);

  Future<void> build() async {
    await controller.write(payload);
  }

  ReceiptBuilder text(
    String text, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    bool containsChinese = false,
    int? maxCharsPerLine,
  }) {
    payload.addAll(generator.text(text,
        styles: styles,
        linesAfter: linesAfter,
        containsChinese: containsChinese,
        maxCharsPerLine: maxCharsPerLine));
    return this;
  }

  ReceiptBuilder setGlobalFont(PosFontType font, {int? maxCharsPerLine}) {
    payload.addAll(
        generator.setGlobalFont(font, maxCharsPerLine: maxCharsPerLine));
    return this;
  }

  ReceiptBuilder setStyles(PosStyles styles, {bool isKanji = false}) {
    payload.addAll(generator.setStyles(styles, isKanji: isKanji));
    return this;
  }

  ReceiptBuilder rawBytes(List<int> cmd, {bool isKanji = false}) {
    payload.addAll(generator.rawBytes(cmd, isKanji: isKanji));
    return this;
  }

  ReceiptBuilder emptyLines(int n) {
    payload.addAll(generator.emptyLines(n));
    return this;
  }

  ReceiptBuilder feed(int n) {
    payload.addAll(generator.feed(n));
    return this;
  }

  ReceiptBuilder cut({PosCutMode mode = PosCutMode.full}) {
    payload.addAll(generator.cut(mode: mode));
    return this;
  }

  ReceiptBuilder reset() {
    payload.addAll(generator.reset());
    return this;
  }

  ReceiptBuilder beep(
      {int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) {
    payload.addAll(generator.beep(n: n, duration: duration));
    return this;
  }

  ReceiptBuilder row(List<PosColumn> cols) {
    payload.addAll(generator.row(cols));
    return this;
  }

  ReceiptBuilder image(img.Image imgSrc, {PosAlign align = PosAlign.center}) {
    payload.addAll(generator.image(imgSrc, align: align));
    return this;
  }

  ReceiptBuilder imageRaster(
    img.Image image, {
    PosAlign align = PosAlign.center,
    bool highDensityHorizontal = true,
    bool highDensityVertical = true,
    PosImageFn imageFn = PosImageFn.bitImageRaster,
  }) {
    payload.addAll(generator.imageRaster(
      image,
      align: align,
      highDensityHorizontal: highDensityHorizontal,
      highDensityVertical: highDensityVertical,
      imageFn: imageFn,
    ));
    return this;
  }

  ReceiptBuilder barcode(
    Barcode barcode, {
    int? width,
    int? height,
    BarcodeFont? font,
    BarcodeText textPos = BarcodeText.below,
    PosAlign align = PosAlign.center,
  }) {
    payload.addAll(generator.barcode(
      barcode,
      width: width,
      height: height,
      font: font,
      textPos: textPos,
      align: align,
    ));
    return this;
  }

  ReceiptBuilder qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.Size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    payload.addAll(generator.qrcode(text, align: align, size: size, cor: cor));
    return this;
  }

  ReceiptBuilder drawer({PosDrawer pin = PosDrawer.pin2}) {
    payload.addAll(generator.drawer(pin: pin));
    return this;
  }

  ReceiptBuilder hr({String ch = '-', int? len, int linesAfter = 0}) {
    payload.addAll(generator.hr(ch: ch, linesAfter: linesAfter));
    return this;
  }

  ReceiptBuilder textEncoded(
    Uint8List textBytes, {
    PosStyles styles = const PosStyles(),
    int linesAfter = 0,
    int? maxCharsPerLine,
  }) {
    payload.addAll(generator.textEncoded(
      textBytes,
      styles: styles,
      linesAfter: linesAfter,
      maxCharsPerLine: maxCharsPerLine,
    ));
    return this;
  }
}
