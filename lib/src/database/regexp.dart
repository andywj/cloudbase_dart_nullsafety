class RegExp {
  String regexp;
  String? options;

  RegExp(this.regexp, [this.options]);

  Map<String, dynamic> toJson() {
    var json = {'\$regex': regexp};

    if (options != null) {
      json['\$options'] = options!;
    }

    return json;
  }
}
