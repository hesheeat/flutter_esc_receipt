abstract class PrinterController {
  Future<void> connect({Duration? timeout});
  Future<void> write(List<int> data);
  Future<void> close();
}
