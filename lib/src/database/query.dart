import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

class QueryOrder {
  String? field;
  String? direction;

  QueryOrder({this.field, this.direction}) {
    assert(direction == 'asc' || direction == 'desc');
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'direction': direction};
  }
}

class QueryOption {
  /// 查询数量
  int limit;

  /// 偏移量
  int offset;

  /// 指定显示或者不显示哪些字段
  dynamic projection;

  QueryOption({this.limit = 1, this.offset = 10, this.projection});
}

class Query {
  /// 上下文
  late CloudBaseCore _core;

  /// Collection Name
  late String _coll;

  /// 过滤条件
  late dynamic _fieldFilters;

  /// 排序条件
  late List<QueryOrder> _fieldOrders;

  /// 查询条件
  late QueryOption _queryOptions;

  /// 请求句柄
  late CloudBaseRequest _request;

  CloudBaseCore get core {
    return _core;
  }

  String get coll {
    return _coll;
  }

  Query({
    required CloudBaseCore core,
    required String coll,
    dynamic fieldFilters,
    List<QueryOrder>? fieldOrders,
    QueryOption? queryOptions,
  }) {
    _core = core;
    _coll = coll;
    _fieldFilters = fieldFilters;
    _fieldOrders = fieldOrders ?? [];
    _queryOptions = queryOptions ?? QueryOption();
    _request = CloudBaseRequest(_core);
  }

  Future<CloudBaseResponse> _queryRequest(
    String action,
    Map<String, dynamic> params,
  ) {
    params.addAll({
      'collectionName': _coll,
      'queryType': 'WHERE',
      'databaseMidTran': true
    });

    return _request.post(action, params);
  }

  Future<DbQueryResponse> get() async {
    Map<String, dynamic> params = {};

    if (_fieldFilters != null) {
      params['query'] = _fieldFilters;
    }

    if (_fieldOrders.isNotEmpty) {
      params['order'] = List.from(_fieldOrders);
    }

    if (_queryOptions.limit != null) {
      params['limit'] = _queryOptions.limit < 1000 ? _queryOptions.limit : 1000;
    } else {
      _queryOptions.limit = 100;
    }

    if (_queryOptions.offset != null) {
      params['offset'] = _queryOptions.offset;
    }

    if (_queryOptions.projection != null) {
      params['projection'] = _queryOptions.projection;
    }

    CloudBaseResponse res =
        await _queryRequest('database.queryDocument', params);
    if (res.code != null) {
      return DbQueryResponse(
          code: res.code, message: res.message, requestId: res.requestId);
    }

    return DbQueryResponse(
        requestId: res.requestId,
        data: Serializer.decode(res.data['list']),
        limit: res.data['limit'],
        offset: res.data['offset']);
  }

  Future<DbQueryResponse> count() async {
    Map<String, dynamic> params = {'query': _fieldFilters};

    CloudBaseResponse res =
        await _queryRequest('database.countDocument', params);
    if (res.code != null) {
      return DbQueryResponse(
          code: res.code, message: res.message, requestId: res.requestId);
    }

    return DbQueryResponse(requestId: res.requestId, total: res.data['total']);
  }

  Future<DbUpdateResponse> update(Map<String, dynamic>? data) async {
    if (data == null) {
      return DbUpdateResponse(
          code: CloudBaseExceptionCode.INVALID_PARAM, message: '参数必需是非空对象');
    }

    if (data.containsKey('_id')) {
      return DbUpdateResponse(
          code: CloudBaseExceptionCode.INVALID_PARAM, message: '不能更新_id的值');
    }

    Map<String, dynamic> params = {
      'query': _fieldFilters,
      'muti': true,
      'merge': true,
      'upsert': false,
      'data': Serializer.encode(data),
      'interfaceCallSource': 'BATCH_UPDATE_DOC'
    };

    CloudBaseResponse res =
        await _queryRequest('database.updateDocument', params);
    if (res.code != null) {
      return DbUpdateResponse(
          code: res.code, message: res.message, requestId: res.requestId);
    }

    return DbUpdateResponse(
        requestId: res.requestId,
        updateId: res.data['upserted_id'],
        updated: res.data['updated']);
  }

  Future<DbRemoveResponse> remove() async {
    if (_queryOptions.offset != null ||
        _queryOptions.limit != null ||
        _queryOptions.projection != null) {
      return DbRemoveResponse(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message:
              '`offset`, `limit` and `projection` are not supported in remove() operation');
    }

    if (_fieldOrders.isNotEmpty) {
      return DbRemoveResponse(
          code: CloudBaseExceptionCode.INVALID_PARAM,
          message: '`orderBy` is not supported in remove() operation');
    }

    Map<String, dynamic> params = {'query': _fieldFilters, 'multi': true};

    CloudBaseResponse res =
        await _queryRequest('database.deleteDocument', params);
    if (res.code != null) {
      return DbRemoveResponse(
          code: res.code, message: res.message, requestId: res.requestId);
    }

    return DbRemoveResponse(
        requestId: res.requestId, deleted: res.data['deleted']);
  }

  Query where(dynamic query) {
    query = Serializer.encode(query);

    return Query(
        core: _core,
        coll: _coll,
        fieldFilters: query,
        fieldOrders: _fieldOrders,
        queryOptions: _queryOptions);
  }

  Query orderBy(String fieldPath, String directionStr) {
    Validater.isFieldPath(fieldPath);
    Validater.isFieldOrder(directionStr);

    var newOrder = QueryOrder(field: fieldPath, direction: directionStr);
    List<QueryOrder> newOrders = List.from(_fieldOrders);
    newOrders.add(newOrder);

    return Query(
        core: _core,
        coll: _coll,
        fieldFilters: _fieldFilters,
        fieldOrders: newOrders,
        queryOptions: _queryOptions);
  }

  Query limit(int limit) {
    var newOptions = QueryOption(
        limit: limit,
        offset: _queryOptions.offset,
        projection: _queryOptions.projection);

    return Query(
        core: _core,
        coll: _coll,
        fieldFilters: _fieldFilters,
        fieldOrders: _fieldOrders,
        queryOptions: newOptions);
  }

  Query skip(int offset) {
    var newOptions = QueryOption(
        limit: _queryOptions.limit,
        offset: offset,
        projection: _queryOptions.projection);

    return Query(
        core: _core,
        coll: _coll,
        fieldFilters: _fieldFilters,
        fieldOrders: _fieldOrders,
        queryOptions: newOptions);
  }

  Query field(Map<String, bool> projection) {
    Map<String, int> newProjection = {};
    projection.forEach((key, value) {
      newProjection[key] = value ? 1 : 0;
    });

    var newOptions = QueryOption(
        limit: _queryOptions.limit,
        offset: _queryOptions.offset,
        projection: newProjection);

    return Query(
        core: _core,
        coll: _coll,
        fieldFilters: _fieldFilters,
        fieldOrders: _fieldOrders,
        queryOptions: newOptions);
  }
}
