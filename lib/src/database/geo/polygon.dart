import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

import 'geo.dart';

class Polygon {
  List<LineString> lines;

  Polygon(this.lines) {
    if (lines.isEmpty) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: 'Polygon must contain 1 linestring at least');
    }
  }

  Map<String, dynamic> toJson() {
    var lineArr = [];
    for (var line in lines) {
      lineArr.add(line.toJson()['coordinates']);
    }

    return {'type': 'Polygon', 'coordinates': lineArr};
  }

  static bool validate(data) {
    if (data['type'] != 'Polygon' || data['coordinates'] is! List) {
      return false;
    }

    List polygon = data['coordinates'];
    for (var i = 0; i < polygon.length; i++) {
      if (polygon[i] is! List) {
        return false;
      }
      List line = polygon[i];

      for (var j = 0; j < line.length; j++) {
        var point = line[j];
        if (!(point[0] is num && point[1] is num)) {
          return false;
        }
      }
    }

    return true;
  }

  static Polygon fromJson(coordinates) {
    List<LineString> lines = [];
    coordinates.forEach((line) {
      lines.add(LineString.fromJson(line));
    });

    return Polygon(lines);
  }
}
