import 'dart:io';

import 'app_database.dart';
import 'background_task_dao.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'background_task_model.dart';
import 'database_isolate_worker.dart';
import 'home_page.dart';

const titleBackground = "periodicTask";
const uniqueKeyBackground = '1';

Future<void> main() async {
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (inputData?['title'].toString() == titleBackground || Platform.isIOS) {
      final AppDatabase appDatabase = AppDatabase();
      await appDatabase.initialize();

      final taskDao = BackgroundTaskDao(appDatabase);
      await taskDao.save(BackgroundTaskModel(
            platform: Platform.isAndroid ? 'Android' : 'IOS',
            taskName: inputData?['title'] ?? '<undefined>',
            executionDateTime: DateTime.now()));
      return Future.value(true);
    }
    return Future.value(false);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoaded = false;

  late final BackgroundTaskDao backgroundTaskDao;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
