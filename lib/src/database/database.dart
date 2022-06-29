import 'package:cloudbase_dart_nullsafety/cloudbase_dart_nullsafety.dart';

class CloudBaseDatabase {
  late CloudBaseCore _core;
  late Command _command;
  late Geo _geo;

  Command get command {
    return _command;
  }

  Geo get geo {
    return _geo;
  }

  CloudBaseDatabase(CloudBaseCore core) {
    _core = core;
    _command = Command();
    _geo = Geo();
  }

  Collection collection(String name) {
    return Collection(_core, name);
  }

  RegExp regExp(String regexp, [String? options]) {
    return RegExp(regexp, options);
  }

  ServerDate serverDate([num? offset]) {
    return ServerDate(offset);
  }
}
