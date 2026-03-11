import 'package:flutter_test/flutter_test.dart';
// Nama project disesuaikan dengan pubspec.yaml Anda
import 'package:logbook_app_001/features/logbook/models/log_model.dart';

void main() {
  group('RBAC & Privacy Security Check', () {
    
    // Inisialisasi data mock untuk pengujian
    final logPublicA = LogModel(
      id: '1',
      title: 'Project Alpha - Public',
      description: 'Progress mingguan tim',
      category: 'Software',
      username: 'User_A',
      timestamp: DateTime.now().toIso8601String(),
      isPublic: true, // Status Publik
    );

    final logPrivateA = LogModel(
      id: '2',
      title: 'Personal Notes - Private',
      description: 'Rahasia riset individu',
      category: 'Research',
      username: 'User_A',
      timestamp: DateTime.now().toIso8601String(),
      isPublic: false, // Status Privat
    );

    final List<LogModel> allLogs = [logPublicA, logPrivateA];

    test('Security Check: Private logs should NOT be visible to teammates', () {
      const currentUserId = 'User_B'; // Simulasi sebagai Anggota Lain

      // Logika Filter: Hanya ambil log milik sendiri ATAU log yang bersifat publik
      final visibleLogsForUserB = allLogs.where((log) {
        return log.username == currentUserId || log.isPublic == true;
      }).toList();

      // Validasi: User B hanya boleh melihat 1 log (yang publik saja)
      expect(visibleLogsForUserB.length, 1);
      expect(visibleLogsForUserB.first.isPublic, isTrue);
      
      // Memastikan log privat User A tidak bocor ke User B
      final containsPrivateLog = visibleLogsForUserB.any((l) => l.id == '2');
      expect(containsPrivateLog, isFalse);
    });

    test('Sovereignty Check: Only owner can manage (Edit/Delete)', () {
      const currentUserId = 'User_B'; // Bukan pemilik
      final logA = logPublicA; // Pemiliknya adalah User_A

      // Aksi Edit/Hapus harus dilarang jika bukan pemilik
      final bool canManage = logA.username == currentUserId;

      expect(canManage, isFalse);
    });

    test('Access Check: Owner can see everything they created', () {
      const currentUserId = 'User_A'; // Pemilik asli

      final visibleLogsForUserA = allLogs.where((log) {
        return log.username == currentUserId || log.isPublic == true;
      }).toList();

      // Pemilik harus bisa melihat log publik maupun privat miliknya
      expect(visibleLogsForUserA.length, 2);
    });
  });
}