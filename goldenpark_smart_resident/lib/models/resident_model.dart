class Resident {
  final int? id;
  final String nama;
  final String blok;
  final String nomorRumah;
  final String noHp;
  final String tanggalMasuk;
  final String status;

  Resident({
    this.id,
    required this.nama,
    required this.blok,
    required this.nomorRumah,
    required this.noHp,
    required this.tanggalMasuk,
    required this.status,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      id: json['id'],
      nama: json['nama'],
      blok: json['blok'],
      nomorRumah: json['nomor_rumah'],
      noHp: json['no_hp'],
      tanggalMasuk: json['tanggal_masuk'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'blok': blok,
      'nomor_rumah': nomorRumah,
      'no_hp': noHp,
      'tanggal_masuk': tanggalMasuk,
      'status': status,
    };
  }
}