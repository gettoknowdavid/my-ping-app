abstract class DbModel<T> {
  static Map<String, dynamic> insert(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  static Map<String, dynamic> update(Map<String, dynamic> data) {
    throw UnimplementedError();
  }

  static dynamic converter(List<Map<String, dynamic>> data) {
    throw UnimplementedError();
  }
}
