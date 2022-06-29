import 'dart:convert';

class DbQueryResponse {
  final String? code;
  final String? message;

  final dynamic data;
  final String? requestId;
  final int? total;
  final int? limit;
  final int? offset;

  DbQueryResponse({
    this.code,
    this.message,
    this.data,
    this.requestId,
    this.total,
    this.limit,
    this.offset,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'data': data,
      'requestId': requestId,
      'total': total,
      'limit': limit,
      'offset': offset,
    };

    return jsonEncode(json);
  }
}

class DbUpdateResponse {
  final String? code;
  final String? message;

  final String? requestId;
  final String? updateId;
  final dynamic updated;

  DbUpdateResponse({
    this.code,
    this.requestId,
    this.message,
    this.updateId,
    this.updated,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'updateId': updateId,
      'updated': updated
    };

    return jsonEncode(json);
  }
}

class DbRemoveResponse {
  final String? code;
  final String? message;

  final String? requestId;
  final dynamic deleted;

  DbRemoveResponse({
    this.code,
    this.message,
    this.requestId,
    this.deleted,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'deleted': deleted
    };

    return jsonEncode(json);
  }
}

class DbCreateResponse {
  final String? code;
  final String? message;

  final String? requestId;
  final String? id;

  DbCreateResponse({
    this.code,
    this.message,
    this.requestId,
    this.id,
  });

  @override
  String toString() {
    var json = {
      'code': code,
      'message': message,
      'requestId': requestId,
      'id': id
    };

    return jsonEncode(json);
  }
}
