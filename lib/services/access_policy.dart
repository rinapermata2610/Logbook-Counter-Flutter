class AccessPolicy {
  /// [TASK 5: SOVEREIGNTY] 
  /// Mengecek apakah user adalah pemilik sah dari log tersebut.
  /// Sekarang, hak edit/hapus HANYA dimiliki oleh pemilik catatan (Owner),
  /// mengabaikan apakah dia 'Ketua' atau bukan.
  static bool canManageLog({
    required String userRole, // Tetap dipertahankan agar tidak merusak parameter yang sudah ada
    required String currentUsername,
    required String logOwner,
  }) {
    // Logika Kedaulatan: Hanya jika nama pengguna saat ini cocok dengan pemilik log.
    // Ketua tim tidak lagi memberikan hak edit/hapus otomatis.
    return currentUsername == logOwner;
  }

  /// [TASK 5: SOVEREIGNTY]
  /// Menghapus aturan lama di mana hanya Ketua yang boleh menghapus.
  /// Sekarang diselaraskan dengan aturan kepemilikan.
  static bool canDeleteLog({
    required String currentUsername,
    required String logOwner,
  }) {
    return currentUsername == logOwner;
  }
}