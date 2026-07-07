class UserModel {
  final String name;
  final String email;

  UserModel({
    required this.name,
    required this.email,
  });

  // Mengonversi JSON Map dari Laravel menjadi Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // Mengonversi Objek Dart kembali ke JSON (jika sewaktu-waktu dibutuhkan)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}