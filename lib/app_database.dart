import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  Completer<Database>? _dbOpenCompleter;
  final String applicationDatabase = 'app_database.db';
  late final Directory appDocumentDir;

  Future<void> initialize() async {
    appDocumentDir = await getApplicationDocumentsDirectory();
  }

  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      await _openDatabase(applicationDatabase);
    }
    return _dbOpenCompleter!.future;
  }

  Future _openDatabase(String databaseName) async {
    final dbPath = join(appDocumentDir.path, databaseName);

    final database = await databaseFactoryIo.openDatabase(dbPath);
    _dbOpenCompleter!.complete(database);
  }
}
