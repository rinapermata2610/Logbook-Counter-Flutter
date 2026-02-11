class CounterController {
  int _counter = 0;
  int _step = 1;

  // Menyimpan riwayat aktivitas (maksimal 5)
  final List<String> _history = [];

  int get value => _counter;
  List<String> get history => _history;

  // Mengatur nilai step
  void setStep(int newStep) {
    if (newStep > 0) {
      _step = newStep;
    }
  }

  // Tambah counter sesuai step
  void increment() {
    _counter += _step;
    _addHistory("User menambah $_step");
  }

  // Kurangi counter sesuai step (tidak boleh negatif)
  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
      _addHistory("User mengurangi $_step");
    }
  }

  // Reset counter
  void reset() {
    _counter = 0;
    _addHistory("User reset counter");
  }

  // Menambahkan log dan membatasi hanya 5 data terakhir
  void _addHistory(String action) {
    final time = DateTime.now().toString().substring(11, 16);
    _history.add("$action pada $time");

    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}
