import 'package:shared_preferences/shared_preferences.dart';

class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  // ================= STEP =================
  void setStep(int step) {
    if (step > 0) _step = step;
  }

  // ================= LOAD DATA =================
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _counter = prefs.getInt('last_counter') ?? 0;

    _history.clear();
    _history.addAll(prefs.getStringList('history') ?? []);
  }

  // ================= SAVE DATA =================
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('last_counter', _counter);
    await prefs.setStringList('history', _history);
  }

  // ================= COUNTER =================
  void increment(String username) {
    _counter += _step;
    _addHistory("$username menambah +$_step");
  }

  void decrement(String username) {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("$username mengurangi -$_step");
    }
  }

  void reset(String username) {
    _counter = 0;
    _addHistory("$username reset counter");
  }

  // ================= HISTORY =================
  void _addHistory(String action) {
    final time = DateTime.now().toString().substring(11, 16);

    _history.add("$action pada $time");

    if (_history.length > 5) {
      _history.removeAt(0);
    }

    _saveData();
  }
}
