import 'package:flutter/foundation.dart';
import 'package:pomotimer/helpers/database.dart';
import 'package:pomotimer/models/history_model.dart';

class HistoryProvider extends ChangeNotifier {
  final DbHelper _dbHelper = DbHelper();

  List<HistoryEvent> history = [];


  HistoryProvider() {
    notifyListeners();
  }

  Future<void> addHistoryEvent(HistoryEvent event) async
  {
    await _dbHelper.insertHistoryEvent(event);
    fetchHistoryEvents();
    notifyListeners();
  }

  Future<void> fetchHistoryEvents() async {
    var list = await _dbHelper.getHistoryEvents();
    history.clear();

    for (var history in list) {
      this.history.add(history);
    }

    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _dbHelper.deleteHistoryEvent();
    history.clear();
    notifyListeners();
  }
}