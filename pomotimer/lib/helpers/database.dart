import 'package:pomotimer/models/history_model.dart';
import 'package:pomotimer/models/timer_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  DbHelper._internal();

  factory DbHelper() => _instance;

  String timerTableName = 'tb_timer';
  String historyTableName = 'tb_history';

  Future<Database?> get _db async {
    if (_database != null) {
      return _database;
    }
    _database = await _initDb();
    return _database;
  }

  Future<Database?> _initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'timer.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute("""
        CREATE TABLE tb_timer (
          focus TEXT DEFAULT '00:25',
          break TEXT DEFAULT '00:05',
          rounds INTEGER DEFAULT 1,
          goals INTEGER DEFAULT 1
        );
        """);

    await db.execute("""
      CREATE TABLE tb_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        event TEXT NOT NULL,
        timestamp TEXT NOT NULL
      );
      """);

    var timerData = TimerData();
    await db.insert(timerTableName, timerData.toMap());
  }

  /*
  TIMER CRUD
   */
  Future<TimerData?> getTimer() async {
    var dbClient = await _db;
    var result = await dbClient!.query(timerTableName);

    if (result.isNotEmpty) {
      return TimerData.fromMap(result.first);
    }
    return null;
  }

  Future<int?> updateTimer(TimerData timer) async {
    var dbClient = await _db;
    return await dbClient!.update(timerTableName, timer.toMap());
  }

  Future<int?> deleteTimer() async {
    var dbClient = await _db;
    return await dbClient!.delete(timerTableName);
  }

  /*
  HISTORY CRUD
   */
  Future<void> insertHistoryEvent(HistoryEvent event) async {
    final db = await _db;
    await db!.insert(historyTableName, event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HistoryEvent>> getHistoryEvents() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db!.query(historyTableName);
    return List.generate(maps.length, (i) {
      return HistoryEvent.fromMap(maps[i]);
    });
  }

  Future<void> deleteHistoryEvent() async {
    final db = await _db;
    await db!.delete(historyTableName);
  }
}
