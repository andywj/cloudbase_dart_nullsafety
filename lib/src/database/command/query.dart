import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

class QueryCommandsLiteral {
  static const AND = 'and';
  static const EQ = 'eq';
  static const NEQ = 'neq';
  static const GT = 'gt';
  static const GTE = 'gte';
  static const LT = 'lt';
  static const LTE = 'lte';
  static const IN = 'in';
  static const NIN = 'nin';
  static const ALL = 'all';
  static const ELEM_MATCH = 'elemMatch';
  static const EXISTS = 'exists';
  static const SIZE = 'size';
  static const MOD = 'mod';
  static const GEO_NEAR = 'geoNear';
  static const GEO_WITHIN = 'geoWithin';
  static const GEO_INTERSECTS = 'geoIntersects';
}

class QueryCommand extends LogicCommand {
  QueryCommand(actions, step) : super(actions, step);

  LogicCommand eq(val) {
    return queryOP(QueryCommandsLiteral.EQ, val);
  }

  LogicCommand neq(val) {
    return queryOP(QueryCommandsLiteral.NEQ, val);
  }

  LogicCommand gt(int val) {
    return queryOP(QueryCommandsLiteral.GT, val);
  }

  LogicCommand gte(int val) {
    return queryOP(QueryCommandsLiteral.GTE, val);
  }

  LogicCommand lt(int val) {
    return queryOP(QueryCommandsLiteral.LT, val);
  }

  LogicCommand lte(int val) {
    return queryOP(QueryCommandsLiteral.LTE, val);
  }

  LogicCommand into(List<dynamic> list) {
    return queryOP(QueryCommandsLiteral.IN, list);
  }

  LogicCommand nin(List<dynamic> list) {
    return queryOP(QueryCommandsLiteral.NIN, list);
  }

  LogicCommand geoNear({Point? geometry, num? maxDistance, num? minDistance}) {
    if (geometry == null) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: '"geometry" can not be null.');
    }

    return queryOP(QueryCommandsLiteral.GEO_NEAR, {
      'geometry': geometry,
      'maxDistance': maxDistance,
      'minDistance': minDistance
    });
  }

  LogicCommand geoWithin(dynamic geometry) {
    if (!(geometry is MultiPolygon || geometry is Polygon)) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: '"geometry" must be of type Polygon or MultiPolygon.');
    }

    return queryOP(QueryCommandsLiteral.GEO_WITHIN, {'geometry': geometry});
  }

  LogicCommand geoIntersects(dynamic geometry) {
    if (!(geometry is Point ||
        geometry is LineString ||
        geometry is Polygon ||
        geometry is MultiPoint ||
        geometry is MultiLineString ||
        geometry is MultiPolygon)) {
      throw CloudBaseException(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message:
              '"geometry" must be of type Point, LineString, Polygon, MultiPoint, MultiLineString or MultiPolygon.');
    }

    return queryOP(QueryCommandsLiteral.GEO_INTERSECTS, {'geometry': geometry});
  }

  LogicCommand queryOP(String cmd, dynamic val) {
    var command = QueryCommand([], ['\$$cmd', val]);

    return and(command);
  }
}
