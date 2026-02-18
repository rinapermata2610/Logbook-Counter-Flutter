import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  void setStep(int step) {
    if (step > 0) _step = step;
  }

  // Memuat data spesifik per user
  Future<void> loadData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    _counter = prefs.getInt('counter_$username') ?? 0;
    _history.clear();
    _history.addAll(prefs.getStringList('history_$username') ?? []);
  }

  Future<void> _saveData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter_$username', _counter);
    await prefs.setStringList('history_$username', _history);
  }

  void increment(String username) {
    _counter += _step;
    _addHistory("$username menambah +$_step", username);
  }

  void decrement(String username) {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("$username mengurangi -$_step", username);
    }
  }

  void reset(String username) {
    _counter = 0;
    _addHistory("$username melakukan reset", username);
  }

  void _addHistory(String action, String username) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.add("$action pada $time");
    if (_history.length > 5) _history.removeAt(0);
    _saveData(username);
  }
}