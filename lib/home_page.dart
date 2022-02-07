import 'dart:io';

import 'app_database.dart';
import 'background_task_dao.dart';
import 'background_task_item.dart';
import 'background_task_model.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<BackgroundTaskModel>? list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Task'),
        actions: [
          IconButton(
            onPressed: () {
              Workmanager().cancelAll();
            },
            icon: const Icon(Icons.cancel_schedule_send),
          )
        ],
      ),
      body: Center(
        child: list != null
            ? ListView.builder(
                itemCount: list!.length,
                itemBuilder: (context, index) =>
                    BackgroundTaskItem(model: list![index]),
              )
            : const Text('Not found'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    if (Platform.isAndroid) {
      Workmanager().registerPeriodicTask(uniqueKeyBackground, titleBackground,
          initialDelay: const Duration(seconds: 30),
          inputData: <String, String>{'title': titleBackground},
          frequency: const Duration(minutes: 15));
    }
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final appDatabase = AppDatabase();
      await appDatabase.initialize();
      final backgroundTaskDao = BackgroundTaskDao(appDatabase);
      list = await backgroundTaskDao.getAll();

      setState(() {});
    });
  }
}
