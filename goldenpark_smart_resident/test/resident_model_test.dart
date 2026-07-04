import 'package:flutter_test/flutter_test.dart';
import 'package:goldenpark_smart_resident/models/resident_model.dart';

void main() {
  test('Resident maps Laravel JSON fields correctly', () {
    final resident = Resident.fromJson({
      'id': 7,
      'nama': 'Budi Santoso',
      'blok': 'A',
      'nomor_rumah': '12',
      'no_hp': '08123456789',
      'tanggal_masuk': '2026-07-04',
      'status': 'Aktif',
    });

    expect(resident.id, 7);
    expect(resident.nama, 'Budi Santoso');
    expect(resident.blok, 'A');
    expect(resident.nomorRumah, '12');
    expect(resident.noHp, '08123456789');
    expect(resident.tanggalMasuk, '2026-07-04');
    expect(resident.status, 'Aktif');

    expect(resident.toJson(), {
      'nama': 'Budi Santoso',
      'blok': 'A',
      'nomor_rumah': '12',
      'no_hp': '08123456789',
      'tanggal_masuk': '2026-07-04',
      'status': 'Aktif',
    });
  });
}
