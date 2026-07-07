class MemberModel {
  final int id;
  final String idMember;
  final String namaLengkap;
  final String alamat;
  final String kota;
  final String kodePos;
  final String email;
  final String noHp;
  final String? createdAt;

  MemberModel({
    required this.id,
    required this.idMember,
    required this.namaLengkap,
    required this.alamat,
    required this.kota,
    required this.kodePos,
    required this.email,
    required this.noHp,
    this.createdAt,
  });

  // Mengubah JSON dari Laravel menjadi Object Dart
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      idMember: json['id_member'] ?? json['member_code'] ?? '',
      namaLengkap: json['nama'] ?? json['nama_lengkap'] ?? '',
      alamat: json['alamat'] ?? '',
      kota: json['kota'] ?? '',
      kodePos: json['kode_pos'] ?? '',
      email: json['email'] ?? '',
      noHp: json['no_hp'] ?? '',
      createdAt: json['created_at'],
    );
  }

  // Digunakan saat membuat member baru
  Map<String, dynamic> toCreateJson() {
    return {
      'nama_lengkap': namaLengkap,
      'alamat': alamat,
      'kota': kota,
      'kode_pos': kodePos,
      'email': email,
      'no_hp': noHp,
    };
  }

  // Digunakan untuk update / serialize object
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_member': idMember,
      'nama_lengkap': namaLengkap,
      'alamat': alamat,
      'kota': kota,
      'kode_pos': kodePos,
      'email': email,
      'no_hp': noHp,
      'created_at': createdAt,
    };
  }
}