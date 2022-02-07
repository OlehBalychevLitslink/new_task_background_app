import 'dart:async';
import 'dart:isolate';

import 'background_task_dao.dart';
import 'background_task_model.dart';
import 'cross_isolates_message.dart';

enum DatabaseOperationStatus { readAll, save, remove }

extension DatabaseOperationStatusExc on DatabaseOperationStatus {
  get isReadAll => this == DatabaseOperationStatus.readAll;
  get isSave => this == DatabaseOperationStatus.save;
  get isRemove => this == DatabaseOperationStatus.remove;
}

class DatabaseIsolateWorker {
  late SendPort newIsolateSendPort;
  Isolate? newIsolate;

  final BackgroundTaskDao _backgroundTaskDao;

  DatabaseIsolateWorker({required BackgroundTaskDao backgroundTaskDao}) :
        _backgroundTaskDao = backgroundTaskDao {
    initialize();
  }

  final _isolateReady = Completer<void>();

  Future<void> get isolateReady => _isolateReady.future;

  Future<void> initialize() async {
    ReceivePort receivePort = ReceivePort();

    receivePort.listen((message){
      if (message is SendPort) {
        newIsolateSendPort = message;
        _isolateReady.complete();
        return;
      }
    });

    newIsolate = await Isolate.spawn(_isolateEntry, receivePort.sendPort);
  }

  static void _isolateEntry(SendPort callerSendPort) {
    final receivePort = ReceivePort();

    callerSendPort.send(receivePort.sendPort);
    receivePort.listen((incomingMessage) async {
      if(incomingMessage is! CrossIsolatesMessage){
        throw Exception('Unknown message format ${incomingMessage.toString()}');
      }

      final keyStatus = incomingMessage.message['key'] as DatabaseOperationStatus;
      final backgroundTaskDao = incomingMessage.message['background_task_dao'] as BackgroundTaskDao;

      if(keyStatus.isReadAll){
        final list = await backgroundTaskDao.getAll();
        incomingMessage.sender.send(list);
      } else if(keyStatus.isRemove || keyStatus.isSave) {
        final model = BackgroundTaskModel.fromJson(incomingMessage.message['model']);
        if(keyStatus.isSave){
          await backgroundTaskDao.save(model);
        } else {
          await backgroundTaskDao.delete(model);
        }
        incomingMessage.sender.send(true);
      }
    });
  }

  Future<void> saveBackgroundTasks(BackgroundTaskModel model) async {
    await _manageBackgroundTasks(model, DatabaseOperationStatus.save);
  }

  Future<void> removeBackgroundTasks(BackgroundTaskModel model) async {
    await _manageBackgroundTasks(model, DatabaseOperationStatus.remove);
  }

  Future<void> _manageBackgroundTasks(BackgroundTaskModel model, DatabaseOperationStatus status) async {
    final port = ReceivePort();

    final massage = CrossIsolatesMessage<Map<String, dynamic>>(
      sender: port.sendPort,
      message: <String, dynamic>{
        'key': status,
        'background_task_dao': _backgroundTaskDao,
        'model': model.toJson()
      }
    );

    newIsolateSendPort.send(massage);
    return port.first;
  }

  void dispose() {
    newIsolate?.kill(priority: Isolate.immediate);
    newIsolate = null;
  }
}