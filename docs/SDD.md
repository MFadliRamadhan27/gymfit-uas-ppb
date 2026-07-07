# SOFTWARE DESIGN DOCUMENT (SDD)

## GymFit – Sistem Informasi Manajemen Member Gym

**Dokumen Desain Perangkat Lunak**

- **Versi Dokumen**: 1.0
- **Tanggal**: 03 Juli 2026
- **Status**: Draft
- **Disusun oleh**: M. Fadli Ramadhan

---

## 1. Pendahuluan

### 1.1 Tujuan

Dokumen _Software Design Document_ (SDD) ini disusun sebagai acuan teknis dalam proses pengembangan aplikasi **GymFit**. Dokumen ini menjelaskan desain perangkat lunak yang berasal dari kebutuhan sistem pada _Product Requirements Document_ (PRD), sehingga dapat digunakan sebagai pedoman implementasi oleh pengembang.

### 1.2 Ruang Lingkup

Dokumen ini mencakup:

- Arsitektur sistem
- Desain database
- Entity Relationship Diagram (ERD)
- Desain REST API
- Struktur folder proyek
- Aturan validasi
- Kebijakan keamanan
- Rencana pengujian

---

## 2. Arsitektur Sistem

Sistem GymFit mengadopsi arsitektur 3-Tier dengan pemisahan yang jelas antara _client_ dan _server_.

```text
Flutter Mobile App
│
│ HTTP Request (JSON)
▼
Laravel REST API
│
│ Eloquent ORM
▼
MySQL Database
```

### 2.1 Presentation Layer

Lapisan ini bertanggung jawab untuk menampilkan antarmuka (UI) dan menangkap interaksi dari pengguna. Diimplementasikan menggunakan aplikasi mobile yang dibangun dengan framework **Flutter**.

### 2.2 Business Layer

Lapisan ini menjalankan semua logika bisnis, memproses data, melakukan validasi, dan menangani otentikasi. Diimplementasikan sebagai **REST API** yang dibangun dengan framework **Laravel**.

### 2.3 Data Layer

Lapisan ini berfungsi sebagai media penyimpanan data yang persisten. Diimplementasikan menggunakan **MySQL** sebagai sistem manajemen basis data relasional.

---

## 3. Komponen Teknologi (Tech Stack)

| Komponen          | Teknologi         |
| :---------------- | :---------------- |
| Backend Framework | Laravel 12        |
| Bahasa Backend    | PHP 8.2+          |
| Mobile Framework  | Flutter 3.x       |
| Bahasa Mobile     | Dart              |
| Database          | MySQL 8 / MariaDB |
| Authentication    | Laravel Sanctum   |
| API Format        | REST API (JSON)   |
| Version Control   | Git               |

---

## 4. Struktur Database & Kamus Data (Data Dictionary)

Sistem ini didukung oleh dua tabel utama: `users` untuk mengelola data otentikasi Admin Gym, dan `members` untuk mengelola data keanggotaan fisik pelanggan.

### 4.1 Tabel: `users` (Admin Account)

Tabel ini menggunakan struktur standar dari Laravel untuk otentikasi.

| Field        | Tipe Data                        | Keterangan                    |
| :----------- | :------------------------------- | :---------------------------- |
| `id`         | `BIGINT UNSIGNED AUTO_INCREMENT` | Primary Key                   |
| `name`       | `VARCHAR(255)`                   | Nama lengkap Admin Gym        |
| `email`      | `VARCHAR(255) UNIQUE`            | Email untuk kebutuhan login   |
| `password`   | `VARCHAR(255)`                   | Password (terenkripsi Bcrypt) |
| `created_at` | `TIMESTAMP`                      | Waktu pembuatan akun          |
| `updated_at` | `TIMESTAMP`                      | Waktu pembaruan akun          |

### 4.2 Tabel: `members` (Gym Membership Data)

Tabel ini menyimpan data operasional member gym sesuai kebutuhan pada PRD.

| Field          | Tipe Data                        |
| :------------- | :------------------------------- |
| `id`           | `BIGINT UNSIGNED AUTO_INCREMENT` |
| `id_member`    | `VARCHAR(20) UNIQUE`             | Di-generate otomatis oleh sistem dengan format M001, M002, dst. |
| `nama_lengkap` | `VARCHAR(100)`                   |
| `alamat`       | `TEXT`                           |
| `kota`         | `VARCHAR(50)`                    |
| `kode_pos`     | `VARCHAR(5)`                     |
| `email`        | `VARCHAR(100) UNIQUE`            |
| `no_hp`        | `VARCHAR(15)`                    |
| `deleted_at`   | `TIMESTAMP NULL`                 |
| `created_at`   | `TIMESTAMP`                      |
| `updated_at`   | `TIMESTAMP`                      |

---

## 5. Entity Relationship Diagram (ERD)

Mengingat cakupan aplikasi manajemen keanggotaan ini berfokus pada efisiensi operasional satu tingkat, entitas `users` (Admin) bertindak sebagai pengelola logis data. Secara struktural database, tabel `members` berdiri sendiri agar proses query filter performanya tetap cepat di bawah kendali _Eloquent Soft Delete trait_.

```text
+--------------------+
| users              |
+--------------------+
| PK id              |
| name               |
| email              |
| password           |
| created_at         |
| updated_at         |
+--------------------+

+--------------------+
| members            |
+--------------------+
| PK id              |
| id_member          |
| nama_lengkap       |
| alamat             |
| kota               |
| kode_pos           |
| email              |
| no_hp              |
| deleted_at         |
| created_at         |
| updated_at         |
+--------------------+

```

---

## 6. Migration Laravel

Berikut adalah rancangan file skema migrasi database di Laravel untuk pembuatan tabel `members`.

```bash
php artisan make:migration create_members_table

```

### Implementasi Kode `database/migrations/xxxx_xx_xx_xxxxxx_create_members_table.php`:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();
            $table->string('member_code', 20)->unique();
            $table->string('name', 100);
            $table->text('address');
            $table->string('city', 50);
            $table->string('postal_code', 5);
            $table->string('email', 100)->unique();
            $table->string('phone', 15);
            $table->softDeletes(); // Membuat kolom 'deleted_at' untuk pengamanan data
            $table->timestamps();  // Membuat kolom 'created_at' dan 'updated_at'
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};

```

---

## 7. Model Laravel

### 7.1 Model `User.php`

Menggunakan model bawaan Laravel dengan aktivasi trait token dari Sanctum.

```php
namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'name', 'email', 'password',
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];
}

```

### 7.2 Model `Member.php`

Mengaktifkan trait `SoftDeletes` agar data terfilter otomatis dari query aktif tanpa benar-benar hilang dari database.

```php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Member extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'members';

    protected $fillable = [
        'member_code',
        'name',
        'address',
        'city',
        'postal_code',
        'email',
        'phone'
    ];

    // Mengonversi kolom deleted_at otomatis menjadi tipe objek Carbon/Datetime
    protected $dates = ['deleted_at'];
}

```

---

## 8. REST API Design

Semua rute operasional dilindungi oleh token Sanctum, kecuali untuk rute otentikasi login.

| Method     | Endpoint            | Fungsi Bisnis                                      | Middleware     |
| ---------- | ------------------- | -------------------------------------------------- | -------------- |
| **POST**   | `/api/login`        | Otentikasi masuk akun Admin, me-return Token       | `guest`        |
| **POST**   | `/api/logout`       | Menghancurkan token Bearer aktif                   | `auth:sanctum` |
| **GET**    | `/api/dashboard`    | Mengambil data total metrik ringkasan dashboard    | `auth:sanctum` |
| **GET**    | `/api/members`      | Mengambil daftar member (Pagination & Search)      | `auth:sanctum` |
| **POST**   | `/api/members`      | Mendaftarkan rekaman member baru ke sistem         | `auth:sanctum` |
| **GET**    | `/api/members/{id}` | Menampilkan rincian profil data satu member        | `auth:sanctum` |
| **PUT**    | `/api/members/{id}` | Memperbarui isian profil data member               | `auth:sanctum` |
| **DELETE** | `/api/members/{id}` | Menjalankan aksi penghapusan logis (_Soft Delete_) | `auth:sanctum` |

---

## 9. Request & Response API Contract

### 9.1 Endpoint: POST `/api/login`

- **Request Body (JSON):**

```json
{
  "email": "admin@gymfit.com",
  "password": "password123"
}
```

- **Response Success (200 OK):**

```json
{
  "success": true,
  "message": "Login berhasil.",
  "token": "1|rahasiaBearerTokenSanctumXyz",
  "user": {
    "id": 1,
    "name": "Admin Ramadhan"
  }
}
```

- **Response Error (401 Unauthorized):**

```json
{
  "success": false,
  "message": "Email atau password salah."
}
```

### 9.2 Endpoint: GET `/api/dashboard`

- **Response Success (200 OK):**

```json
{
  "success": true,
  "data": {
    "total_member": 120,
    "member_baru_bulan_ini": 15,
    "recent_members": [
      {
        "id": 5,
        "member_code": "M005",
        "name": "Fahra Ragita",
        "city": "Bandung"
      },
      {
        "id": 4,
        "member_code": "M004",
        "name": "M. Fadli R.",
        "city": "Banjarmasin"
      }
    ]
  }
}
```

### 9.3 Endpoint: GET `/api/members` (Dengan Pagination dan Fitur Search)

- **Contoh Request URL:** `/api/members?page=1&search=Banjarmasin`
- **Response Success (200 OK):**

```json
{
  "success": true,
  "data": [
    {
      "id": 4,
      "member_code": "M004",
      "name": "M. FADLI RAMADHAN",
      "city": "Banjarmasin",
      "email": "fadli@poliban.ac.id"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 10,
    "total_data": 1,
    "has_more_pages": false
  }
}
```

### 9.4 Endpoint: POST `/api/members` (Tambah Member)

- **Request Body (JSON):**

```json
{
  "member_code": "M006",
  "name": "Ahmad Dani",
  "address": "Jl. Kayutangi No. 12",
  "city": "Banjarmasin",
  "postal_code": "70123",
  "email": "dani@poliban.ac.id",
  "phone": "0812555001"
}
```

- **Response Success (201 Created):**

```json
{
  "success": true,
  "message": "Member baru berhasil didaftarkan.",
  "data": { "id": 6, "member_code": "M006" }
}
```

---

## 10. Validasi Data (Server-Side Rules)

Guna mengawal integritas basis data, seluruh inputan POST dan PUT pada modul pendaftaran member dikawal oleh aturan validasi ketat Laravel Form Request berikut:

| Field         | Rule Aturan (Laravel Syntax) | Keterangan Aturan Bisnis |
| ------------- | ---------------------------- | ------------------------ | ---------------------------------------------- | --------------------------------------------------- | ------------------------------------------------- |
| `member_code` | `required                    | string                   | max:20                                         | unique:members,member_code`                         | Wajib ada, teks, max 20 kar, tidak boleh duplikat |
| `name`        | `required                    | string                   | max:100                                        | regex:/^[a-zA-Z\s]+$/`                              | Wajib ada, hanya huruf alfabet dan spasi          |
| `address`     | `required                    | string`                  | Wajib ada, menampung teks panjang alamat rumah |
| `city`        | `required                    | string                   | max:50`                                        | Wajib ada, teks nama kota                           |
| `postal_code` | `required                    | numeric                  | digits:5`                                      | Wajib ada, angka murni harus bernilai tepat 5 digit |
| `email`       | `required                    | email                    | max:100                                        | unique:members,email`                               | Wajib ada, pola surel valid, unik di database     |
| `phone`       | `required                    | numeric                  | digits_between:10,15                           | starts_with:08`                                     | Wajib ada, angka murni, panjang 10-15, awal `08`  |

---

## 11. Struktur Folder Backend (Laravel 12)

```text
backend-laravel/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── AuthController.php        <--- Kontrol Login & Logout
│   │   │   ├── DashboardController.php   <--- Kontrol Metrik Dashboard & Empty State
│   │   │   └── MemberController.php      <--- Kontrol CRUD, Search, & Soft Delete
│   │   └── Middleware/
│   └── Models/
│       ├── User.php
│       └── Member.php                    <--- Defisini Eloquent & Soft Delete Trait
├── database/
│   ├── migrations/
│   │   ├── 2014_10_12_000000_create_users_table.php
│   │   └── 2026_07_02_000000_create_members_table.php
│   └── seeders/
│       └── DatabaseSeeder.php            <--- Seeder data dummy Admin & Member
├── routes/
│   └── api.php                           <--- Deklarasi Rute REST API Terproteksi
└── .env                                  <--- Pengaturan Database Konfigurasi

```

---

## 12. Struktur Folder Mobile (Flutter)

```text
mobile-flutter/
├── lib/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── member_model.dart              <--- Serialisasi JSON Mapper data member
│   ├── services/
│   │   ├── api_service.dart               <--- Base konfigurasi HTTP Client Client
│   │   ├── auth_service.dart              <--- Pengelola Request Token Login
│   │   └── member_service.dart            <--- Operator Request CRUD ke API Laravel
│   ├── screens/
│   │   ├── login_screen.dart              <--- UI Layar Masuk Akun
│   │   ├── dashboard_screen.dart          <--- UI Layar Utama & Penanganan Empty State
│   │   ├── member_list_screen.dart        <--- UI Tabel List, Search, & Pagination
│   │   ├── member_form_screen.dart        <--- UI Input Form (Aksi Tambah & Edit)
│   │   └── member_detail_screen.dart      <--- UI Tampilan Rinci Profil
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   └── member_card.dart
│   ├── utils/
│   │   └── constants.dart                 <--- Menyimpan Base URL API (e.g. 10.0.2.2)
│   └── main.dart                          <--- Titik Mulai Aplikasi & Cek Sesi Token

```

---

## 13. Diagram Alur API (API Authentication Flow)

```text
Flutter Mobile App                   Laravel REST API                  Database MySQL
        |                                   |                                 |
        | --- 1. POST /login (JSON) ------> |                                 |
        |                                   | --- 2. Cek Akun & Password ---> |
        |                                   | <--- 3. Akun Valid ------------ |
        |                                   |                                 |
        |                                   | --- 4. Generate Token --------> |
        |                                   | <--- 5. Token Tersimpan ------- |
        | <--- 6. Return Bearer Token ----- |                                 |
        |    (Simpan Lokal di HP via SP)    |                                 |

```

---

## 14. Diagram Alur CRUD Member

### 14.1 Alur Tambah & Edit Data

```text
[Layar Form Flutter] ➔ [Validasi Form Lokal Flutter] ➔ [Kirim Data JSON ke API]
                                                               │
     ┌─────────────────── [Gagal Validasi API] ◄───────────────┤
     ▼                                                         ▼
[Render Pesan Error Red-Marking]              [Proses Query Simpan/Update DB]
                                                               │
                                                               ▼
[Arahkan ke List Member] ◄────── [Return JSON Success (201)] ──┘

```

### 14.2 Alur Soft Delete (Hapus Logis)

```text
[Klik Tombol Hapus] ➔ [Tampilkan AlertDialog Konfirmasi] ➔ [Kirim HTTP DELETE Token]
                                                                     │
                                                                     ▼
[Hilang dari List App] ◄── [Return Sukses JSON] ◄── [Isi Kolom deleted_at di DB MySQL]

```

---

## 15. Kebijakan Keamanan (Security Policy)

1. **Token Bearer Terproteksi:** Seluruh transmisi data operasional setelah fase login diproteksi oleh _middleware_ `auth:sanctum`. Klien Flutter wajib menyematkan header `Authorization: Bearer <token_kamu>` pada setiap panggilan data.
2. **Kriptografi Password:** Kata sandi Admin disimpan menggunakan algoritma _hashing_ satu arah `Bcrypt` melalui fungsi bawaan `Hash::make()` di Laravel.
3. **Pengamanan Layer Data (Soft Delete):** Eksekusi perintah `$member->delete()` tidak memicu instruksi SQL `DELETE FROM`. Melainkan mengaktifkan tanda penunjuk waktu pada field `deleted_at`. Sistem secara otomatis mengisolasi rekaman bertanda tersebut dari query regular `SELECT`.
4. **Validasi Berlapis:** Menerapkan validasi ganda (_Double-Gate Validation_). Validasi tipe karakter di sisi Flutter untuk kenyamanan UX, dan validasi keunikan (`unique`) di sisi Laravel untuk mengunci keamanan basis data.

---

## 16. Rencana Pengujian (Test Matrix Manual via Postman)

Matriks pengujian internal sebelum aplikasi siap dikunci untuk penilaian UAS:

| ID Test   | Endpoint / Fitur    | Skenario Skenario Masukan                       | Hasil yang Diharapkan (Expected Result)                    | Status    |
| --------- | ------------------- | ----------------------------------------------- | ---------------------------------------------------------- | --------- |
| **TC-01** | `/api/login`        | Memasukkan kombinasi password yang salah        | Menolak akses, return HTTP 401, error message sesuai       | `Pending` |
| **TC-02** | `/api/login`        | Memasukkan kredensial admin yang terdaftar      | Sukses masuk, return HTTP 200, mengembalikan string token  | `Pending` |
| **TC-03** | `/api/dashboard`    | Mengakses dashboard tanpa menyertakan Token     | Memblokir request, return HTTP 401 Unauthorized            | `Pending` |
| **TC-04** | `/api/dashboard`    | Mengakses dashboard dengan kondisi data 0       | HTTP 200 OK, metrik berisi angka 0, array data kosong      | `Pending` |
| **TC-05** | `/api/members`      | Mendaftarkan member dengan Email yang sudah ada | Validasi menolak data, memicu pesan error duplikasi        | `Pending` |
| **TC-06** | `/api/members`      | Mengetik nama "Dani" di kolom pencarian         | Mengembalikan daftar baris yang mengandung unsur "Dani"    | `Pending` |
| **TC-07** | `/api/members/{id}` | Menjalankan fungsi HTTP DELETE                  | Baris data hilang dari aplikasi, kolom `deleted_at` terisi | `Pending` |
| **TC-08** | `/api/logout`       | Menekan tombol keluar aplikasi                  | Token di database dihancurkan, token lokal HP dihapus      | `Pending` |
