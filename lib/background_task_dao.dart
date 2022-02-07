
import 'package:sembast/sembast.dart';
import 'app_database.dart';
import 'background_task_model.dart';

const String backgroundTaskDataStorage = 'background_task_data_storage';

class BackgroundTaskDao {
  final AppDatabase _appDatabase;

  BackgroundTaskDao(this._appDatabase);

  final _backgroundTaskDataStorage =
      stringMapStoreFactory.store(backgroundTaskDataStorage);

  Future<Database> get _db async => _appDatabase.database;

  Future<void> delete(BackgroundTaskModel model) async {
    final finder = Finder(filter: Filter.byKey(model.uuid));
    await _backgroundTaskDataStorage.delete(await _db, finder: finder);
  }

  Future<BackgroundTaskModel> get(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final snapshot =
        await _backgroundTaskDataStorage.findFirst(await _db, finder: finder);

    if (snapshot != null && snapshot.value.isNotEmpty) {
      return BackgroundTaskModel.fromJson(snapshot.value);
    } else {
      throw Exception('Movie not found');
    }
  }

  Future<List<BackgroundTaskModel>> getAll() async {
    final recordSnapshots = await _backgroundTaskDataStorage.find(await _db,
        finder: Finder(sortOrders: [SortOrder('execution_date_time', false)]));
    final backgroundTasks = <BackgroundTaskModel>[];

    print("data items = ${recordSnapshots.length}");

    for (var snapshot in recordSnapshots) {
      backgroundTasks.add(BackgroundTaskModel.fromJson(snapshot.value));
    }

    return backgroundTasks;
  }

  Future<void> save(BackgroundTaskModel model) async {
    final result = await _backgroundTaskDataStorage
        .record(model.uuid)
        .put(await _db, model.toJson());
  }

  Future<void> update(BackgroundTaskModel model) async {
    final finder = Finder(filter: Filter.byKey(model.uuid));
    await _backgroundTaskDataStorage.update(await _db, model.toJson(),
        finder: finder);
  }
}
