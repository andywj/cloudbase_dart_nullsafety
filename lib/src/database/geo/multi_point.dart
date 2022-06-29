import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

import 'geo.dart';

class MultiPoint {
  List<Point> points;

  MultiPoint(this.points) {
    if (points.isEmpty) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: 'points must contain 1 point at least');
    }
  }

  Map<String, dynamic> toJson() {
    var pointArr = [];
    for (var point in points) {
      pointArr.add(point.toJson()['coordinates']);
    }

    return {'type': 'MultiPoint', 'coordinates': pointArr};
  }

  static bool validate(data) {
    if (data['type'] != 'MultiPoint' || data['coordinates'] is! List) {
      return false;
    }

    List multiPoint = data['coordinates'];
    for (var i = 0; i < multiPoint.length; i++) {
      var point = multiPoint[i];
      if (!(point[0] is num && point[1] is num)) {
        return false;
      }
    }

    return true;
  }

  static MultiPoint fromJson(coordinates) {
    List<Point> points = [];
    coordinates.forEach((point) {
      points.add(Point.fromJson(point));
    });

    return MultiPoint(points);
  }
}
