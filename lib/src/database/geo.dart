import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

class Geo {
  Point point(num longitude, num latitude) {
    return Point(longitude, latitude);
  }

  MultiPoint multiPoint(List<Point> points) {
    return MultiPoint(points);
  }

  LineString lineString(List<Point> points) {
    return LineString(points);
  }

  MultiLineString multiLineString(List<LineString> lines) {
    return MultiLineString(lines);
  }

  Polygon polygon(List<LineString> lines) {
    return Polygon(lines);
  }

  MultiPolygon multiPolygon(List<Polygon> polygons) {
    return MultiPolygon(polygons);
  }
}
