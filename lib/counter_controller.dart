class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<String> _history = [];

  int get value => _counter;
  int get step => _step;
  List<String> get history => _history;

  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  void increment() {
    _counter += _step;
    _addHistory("User menambah $_step");
  }

  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("User mengurangi $_step");
    }
  }

  void reset() {
    _counter = 0;
    _addHistory("User reset counter");
  }

  void _addHistory(String action) {
    final time = DateTime.now().toString().substring(11, 16);

    _history.add("$action pada $time");

    // hanya simpan 5 terakhir
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}
