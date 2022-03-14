/// extension for converting list<int> to Unit8 to work with win32
extension IntParsing on List<int> {
  List<List<int>> chunkBy(num value) {
    List<List<int>> result = [];
    final size = length;
    int max = size ~/ value;
    int check = size % (value as int);
    if (check > 0) {
      max += 1;
    }
    if (size <= value) {
      result = [this];
    } else {
      for (var i = 0; i < max; i++) {
        int startIndex = value * i;
        int endIndex = value * (i + 1);
        if (endIndex > size) {
          endIndex = size;
        }
        var sub = sublist(startIndex, endIndex);
        // print("startIndex=$startIndex || endIndex=$endIndex");
        result.add(sub);
      }
    }
    return result;
  }
}
