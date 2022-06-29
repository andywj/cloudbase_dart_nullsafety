import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';
import 'package:test/test.dart';

import 'case/interface_collection_p0.dart' as collection_p0;
import 'case/interface_command_p0.dart' as command_p0;
import 'case/interface_geo_p0.dart' as geo_p0;

void main() async {
  CloudBaseCore core = CloudBaseCore.init({
    'env': 'test-cloud-5f25f8',
    'secretId': 'AKIDpGg1BBrgrsjYDgoWr384qcGj7KMEMQXU',
    'secretKey': 'vkOrCOPtDNSM4d5MBqKzUo197HI8pSwd'
  });
  CloudBaseDatabase db = CloudBaseDatabase(core);

  /// collection p0用例
  test(collection_p0.cases_data['name'], () async {
    List cases = collection_p0.cases_data['cases'] as List;
    for (var i = 0; i < cases.length; i++) {
      await runCases(db, cases[i]);
    }
  }, timeout: Timeout(Duration(minutes: 60)));

  /// command p0用例
  test(command_p0.cases_data['name'], () async {
    List cases = command_p0.cases_data['cases'] as List;
    for (var i = 0; i < cases.length; i++) {
      print(cases[i]);
      await runCases(db, cases[i]);
    }
  }, timeout: Timeout(Duration(minutes: 60)));

  /// geo command p0用例
  test(geo_p0.cases_data['name'], () async {
    List cases = geo_p0.cases_data['cases'] as List;
    for (var i = 0; i < cases.length; i++) {
      await runCases(db, cases[i]);
    }
  }, timeout: Timeout(Duration(minutes: 60)));

  /// server date p0用例
  test('server_data p0用例', () async {
    var collection = db.collection('doc_wcc');
    var res = await collection
        .add({'description': 'eat an apple', 'createTime': db.serverDate()});
    expect(res.code == null, true);

    var res2 = await collection.doc(res.id).get();
    expect(res2.code == null, true);
    expect(res2.data[0]['createTime'] is DateTime, true);
  });
}

Future<dynamic> collectionOp(
    CloudBaseDatabase db, String cmd, dynamic event) async {
  var collection = db.collection(event['collection_name']);

  switch (cmd) {
    case 'collection_doc':
      return collection.doc(event['record_id']).get();

    case 'collection_get':
      if (event['skip'] != null) {
        collection = collection..skip(event['skip']);
      }
      if (event['filter'] != null) {
        collection = collection..where(event['filter']);
      }
      if (event['limit'] != null) {
        collection = collection..limit(event['limit']);
      }
      if (event['order_key'] != null && event['order_type'] != null) {
        collection = collection
          ..orderBy(event['order_key'], event['order_type']);
      }
      if (event['field'] != null) {
        collection = collection..field(event['field']);
      }
      return collection.get();

    case 'collection_search':
      return collection
          .where(event['filter'])
          .skip(event['skip'])
          .limit(event['limit'])
          .orderBy(event['order_key'], event['order_type'])
          .field(event['field'])
          .get();

    case 'collection_add':
      return collection.add(event['data']);

    case 'collection_update':
      return collection.where(event['filter']).update(event['data']);

    case 'collection_remove':
      return collection.where(event['filter']).remove();

    case 'collection_count':
      return collection.where({'_id': db.command.neq('undefined')}).count();

    case 'collection_where':
      return collection.where(event['filter']).get();

    case 'collection_orderBy':
      return collection.orderBy(event['order_key'], event['order_type']).get();

    case 'collection_limit':
      return collection.limit(event['limit']).get();

    case 'collection_skip':
      return collection.where(event['filter']).skip(event['skip']).get();

    case 'collection_field':
      return collection.field(event['field']).get();

    case 'collection_clean':
      DbQueryResponse res = await collection.get();
      List coll = res.data;
      return Future.wait(coll.map((doc) {
        return collection.doc(doc['_id']).remove();
      }));

    default:
      return null;
  }
}

Future<dynamic> docOp(CloudBaseDatabase db, String cmd, dynamic event) async {
  var doc = db.collection(event['collection_name']).doc(event['doc_id']);

  switch (cmd) {
    case 'doc_get':
      return doc.get();

    case 'doc_set':
      return doc.set(event['data']);

    case 'doc_update':
      return doc.update(event['data']);

    case 'doc_remove':
      return doc.remove();

    default:
  }
}

Future<dynamic> commandOp(
    CloudBaseDatabase db, String cmd, dynamic event) async {
  var collection = db.collection(event['collection_name']);
  var _ = db.command;

  switch (cmd) {
    case 'command_eq':
      return collection.where({event['eq_key']: _.eq(event['eq_value'])}).get();

    case 'command_neq':
      return collection
          .where({event['neq_key']: _.neq(event['neq_value'])}).get();

    case 'command_lt':
      return collection.where({event['lt_key']: _.lt(event['lt_value'])}).get();

    case 'command_lte':
      return collection
          .where({event['lte_key']: _.lte(event['lte_value'])}).get();

    case 'command_gt':
      return collection.where({event['gt_key']: _.gt(event['gt_value'])}).get();

    case 'command_gte':
      return collection
          .where({event['gte_key']: _.gte(event['gte_value'])}).get();

    case 'command_in':
      return collection
          .where({event['in_key']: _.into(event['in_value'])}).get();

    case 'command_nin':
      return collection
          .where({event['nin_key']: _.nin(event['nin_value'])}).get();

    case 'command_and':
      return collection.where({
        event['and_key']:
            _.and([_.gt(event['and_value0']), _.lt(event['and_value1'])])
      }).get();

    case 'command_or':
      return collection.where({
        event['or_key']:
            _.or([_.gt(event['or_value0']), _.lt(event['or_value1'])])
      }).get();

    case 'command_set':
      return collection
          .doc(event['doc_id'])
          .update({event['set_key']: _.set(event['set_value'])});

    case 'command_remove':
      return collection
          .doc(event['doc_id'])
          .update({event['remove_key']: _.remove()});

    case 'command_inc':
      return collection
          .doc(event['doc_id'])
          .update({event['inc_key']: _.inc(event['inc_value'])});

    case 'command_mul':
      return collection
          .doc(event['doc_id'])
          .update({event['mul_key']: _.mul(event['mul_value'])});

    case 'command_push':
      return collection
          .doc(event['doc_id'])
          .update({event['push_key']: _.push(event['push_value'])});

    case 'command_pop':
      return collection
          .doc(event['doc_id'])
          .update({event['pop_key']: _.pop()});

    case 'command_shift':
      return collection
          .doc(event['doc_id'])
          .update({event['shift_key']: _.shift()});

    case 'command_unshift':
      return collection
          .doc(event['doc_id'])
          .update({event['unshift_key']: _.unshift(event['unshift_value'])});

    case 'command_geoNear':
      return collection.where({
        event['geoNear_key']: _.geoNear(
          event['geoNear_value']['geometry'],
          maxDistance: event['geoNear_value']['maxDistance'],
          minDistance: event['geoNear_value']['minDistance'],
        )
      }).get();

    case 'command_geoWithin':
      return collection.where({
        event['geoWithin_key']:
            _.geoWithin(event['geoWithin_value']['geometry'])
      }).get();

    case 'command_geoIntersects':
      return collection.where({
        event['geoIntersects_key']:
            _.geoIntersects(event['geoIntersects_value']['geometry'])
      }).get();

    default:
      return null;
  }
}

Future<void> runCases(db, element) async {
  var event = element['request'];
  String cmd = event['cmd'];
  print(element['desc']);

  dynamic res;
  if (cmd.startsWith('collection')) {
    res = await collectionOp(db, cmd, event);
  } else if (cmd.startsWith('doc')) {
    res = await docOp(db, cmd, event);
  } else if (cmd.startsWith('command')) {
    res = await commandOp(db, cmd, event);
  }

  expect(res is List || res != null, true);
  if (element['expect'] != null) {
    expect(element['expect'](res), true);
  }
}
