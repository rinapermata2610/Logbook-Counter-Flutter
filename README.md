## Self Reflection – Single Responsibility Principle (SRP)

Prinsip SRP membantu saat menambahkan fitur History Logger karena logika aplikasi dan tampilan sudah terpisah.

CounterController hanya mengelola data dan perhitungan, sedangkan CounterView fokus pada UI.

Saat fitur riwayat ditambahkan, perubahan cukup dilakukan pada Controller tanpa mengganggu struktur tampilan. Hal ini membuat kode lebih rapi, mudah dikembangkan, dan mudah dipelihara.
