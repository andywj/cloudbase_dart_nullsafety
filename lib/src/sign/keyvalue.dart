class SortedKeyValue {
  final List<String> keys = [];
  final List<dynamic> values = [];
  final List<List<dynamic>> pairs = [];

  final Map<String, dynamic> _obj = {};

  SortedKeyValue(dynamic obj, [List<String>? selectkeys]) {
    if (obj is! Map) {
      return;
    }

    (obj as Map<String, dynamic>? ?? {}).keys.toList()
      ..sort((a, b) {
        // final localeA = Intl.message(a, locale: 'en');
        // final localeB = Intl.message(b, locale: 'en');

        // print(localeA);
        // print(localeB);

        // return localeA.compareTo(localeB);
        return (a.toLowerCase().trim().compareTo(b.toLowerCase().trim()));
      })
      ..forEach((key) {
        if (selectkeys?.contains(key) ?? true) {
          keys.add(key);
          values.add(obj[key]);
          pairs.add([key, obj[key]]);
          _obj[key.toLowerCase()] = obj[key];
        }
      });
  }

  dynamic get(String key) {
    return _obj[key];
  }

  @override
  String toString({String kvSeparator = '=', String joinSeparator = '&'}) {
    return pairs.map((pair) {
      return pair.join(kvSeparator);
    }).join(joinSeparator);
  }
}
