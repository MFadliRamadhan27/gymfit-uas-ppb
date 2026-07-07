---

# Dokumentasi REST API - GymFit Backend (v1.0)

Dokumentasi ini memuat spesifikasi lengkap *endpoint* REST API untuk aplikasi manajemen keanggotaan **GymFit**. Dijelaskan secara rinci untuk menyelaraskan integrasi antara backend Laravel dan frontend Flutter.

---

## 📌 Informasi API & Versi

* **API Version:** v1.0
* **Backend Framework:** Laravel 12 (PHP 8.4)
* **Database:** MySQL
* **Frontend Stack:** Flutter 3.41 (Dio, Provider, SharedPreferences)
* **Autentikasi:** Laravel Sanctum (Bearer Token)
* **Format Data:** `application/json`

---

## 🏗️ Diagram Arsitektur Sistem

```text
   ┌──────────────────────┐
   │     Flutter App      │  (Frontend - Android Device / Emulator)
   └──────────┬───────────┘
              │
              │ Request via HTTP Client (Dio)
              ▼
   ┌──────────────────────┐
   │  REST API Laravel    │  (Backend Controller & Sanctum Auth)
   └──────────┬───────────┘
              │
              │ Query SQL (Eloquent ORM)
              ▼
   ┌──────────────────────┐
   │    MySQL Database    │  (Data Store Physical)
   └──────────────────────┘

```

---

## 🌐 Base URL & Konfigurasi Jaringan

Sistem menyediakan dua alamat akses lokal tergantung dari lingkungan (*environment*) perangkat yang digunakan untuk menguji:

* **Base URL Lokal:** `[http://127.0.0.1:8000/api](http://127.0.0.1:8000/api)`
* **Base URL Emulator Android:** `[http://10.0.2.2:8000/api](http://10.0.2.2:8000/api)`

> 💡 **Catatan Penting:** Alamat `127.0.0.1` digunakan ketika Anda menguji atau mengakses API melalui *browser* atau Postman di komputer lokal. Sementara alamat `10.0.2.2` merupakan IP khusus yang digunakan oleh Android Emulator agar dapat mengenali dan terhubung ke rute `localhost` milik sistem operasi komputer Anda.

---

## 🔐 Alur Autentikasi (Authentication Flow)

```text
 [ Admin Login ] ──> Kirim Email & Password via POST /login
                         │
                         ▼
             [ Mendapatkan Access Token ] ──> Access Token dikembalikan pada response JSON
                         │
                         ▼
             [ Simpan di SharedPreferences ] ──> Token disimpan permanen di internal HP
                         │
                         ▼
             [ Request Protected Route ] ──> Flutter menyisipkan Header 'Authorization: Bearer <token>'
                         │
                         ▼
 [ Admin Logout ] ──> Hancurkan Token di Database via POST /logout & Hapus dari HP

```

---

## 📊 Ringkasan Endpoint

| No | Metode | Endpoint | Proteksi Token | Keterangan |
| --- | --- | --- | --- | --- |
| 1 | `POST` | `/login` | ❌ Publik | Autentikasi Admin & Generate Token |
| 2 | `GET` | `/me` | Terproteksi | Mengambil data profil Admin yang aktif |
| 3 | `GET` | `/dashboard` | Terproteksi | Mengambil ringkasan statistik & 5 member terbaru |
| 4 | `GET` | `/members` | Terproteksi | Menampilkan semua data member (Fitur `?search=`) |
| 5 | `POST` | `/members` | Terproteksi | Menambahkan member baru (`id_member` otomatis backend) |
| 6 | `GET` | `/members/{id}` | Terproteksi | Menampilkan detail data dari 1 orang member |
| 7 | `PUT` | `/members/{id}` | Terproteksi | Memperbarui/mengubah data profil member |
| 8 | `DELETE` | `/members/{id}` | Terproteksi | Menghapus member secara permanen dari database (*Hard Delete*) |
| 9 | `POST` | `/logout` | Terproteksi | Menghapus sesi aktif & menghancurkan token akses |

---

## 📂 Detail Endpoint

### 1. Login Admin

Memverifikasi kredensial akun admin dan menghasilkan *Bearer Token*.

* **URL:** `/login`
* **Metode:** `POST`
* **Body (JSON):**

```json
{
  "email": "admin@gymfit.com",
  "password": "password123"
}

```

* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Autentikasi berhasil, selamat datang.",
  "access_token": "1|laravel_sanctum_token_hash_di_sini...",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "Admin GymFit",
    "email": "admin@gymfit.com"
  }
}

```

---

### 2. Profil Admin Aktif (`/me`)

Mengambil informasi akun admin yang sedang memegang sesi login aktif.

* **URL:** `/me`
* **Metode:** `GET`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Data profil pengguna berhasil diambil.",
  "data": {
    "id": 1,
    "name": "Admin GymFit",
    "email": "admin@gymfit.com"
  }
}

```

---

### 3. Statistik Dasbor

Mengambil data agregasi angka dan riwayat pendaftaran untuk halaman utama aplikasi Flutter.

* **URL:** `/dashboard`
* **Metode:** `GET`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Data statistik dasbor berhasil dimuat.",
  "data": {
    "total_member": 3,
    "member_baru_bulan_ini": 3,
    "member_terbaru": [
      {
        "id": 3,
        "id_member": "GYM-0003",
        "nama_lengkap": "Siti Aminah",
        "alamat": "Jl. Panglima Batur",
        "kota": "Banjarbaru",
        "kode_pos": "70711",
        "email": "aminah@gymfit.com",
        "no_hp": "085344556677",
        "created_at": "2026-07-07T12:10:00.000000Z"
      }
    ]
  }
}

```

---

### 4. Tampilkan Semua Member & Pencarian

Mengambil seluruh data member yang terdaftar di sistem tanpa pembagian halaman (*non-pagination*). Mendukung pencarian dinamis berbasis nama atau ID melalui parameter *query string* `search`.

* **URL:** `/members` atau `/members?search=Fadli`
* **Metode:** `GET`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Daftar data member berhasil diambil.",
  "data": [
    {
      "id": 1,
      "id_member": "GYM-0001",
      "nama_lengkap": "M. Fadli Ramadhan",
      "alamat": "Jl. H. Hasan Basri",
      "kota": "Banjarmasin",
      "kode_pos": "70123",
      "email": "fadli@gymfit.com",
      "no_hp": "081234567890"
    }
  ]
}

```

---

### 5. Tambah Member Baru

Mendaftarkan member baru ke dalam sistem. Format `id_member` diatur dan dibuat secara otomatis oleh sistem logis di backend Laravel sehingga tidak perlu dikirim melalui *request body*.

* **URL:** `/members`
* **Metode:** `POST`
* **Body (JSON):**

```json
{
  "nama_lengkap": "Rendy Pangalila",
  "alamat": "Jl. Sultan Adam No. 12",
  "kota": "Banjarmasin",
  "kode_pos": "70124",
  "email": "rendy@gymfit.com",
  "no_hp": "081399887766"
}

```

* **Respons Sukses (201 Created):**

```json
{
  "success": true,
  "message": "Data member baru berhasil ditambahkan.",
  "data": {
    "id": 4,
    "id_member": "GYM-0004",
    "nama_lengkap": "Rendy Pangalila",
    "alamat": "Jl. Sultan Adam No. 12",
    "kota": "Banjarmasin",
    "kode_pos": "70124",
    "email": "rendy@gymfit.com",
    "no_hp": "081399887766"
  }
}

```

---

### 6. Detail Profil 1 Member

Mengambil informasi lengkap satu member tertentu berdasarkan ID internal database untuk kebutuhan halaman detail *frontend*.

* **URL:** `/members/{id}` (Contoh: `/members/1`)
* **Metode:** `GET`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Detail data member berhasil ditemukan.",
  "data": {
    "id": 1,
    "id_member": "GYM-0001",
    "nama_lengkap": "M. Fadli Ramadhan",
    "alamat": "Jl. H. Hasan Basri",
    "kota": "Banjarmasin",
    "kode_pos": "70123",
    "email": "fadli@gymfit.com",
    "no_hp": "081234567890"
  }
}

```

---

### 7. Perbarui/Ubah Data Member

Mengubah data profil keanggotaan member yang sudah terdaftar di database. Prosedur ini tidak membutuhkan parameter `id_member` di dalam *request body* karena ID bersifat statis dan dikunci oleh sistem backend.

* **URL:** `/members/{id}` (Contoh: `/members/1`)
* **Metode:** `PUT`
* **Body (JSON):**

```json
{
  "nama_lengkap": "M. Fadli Ramadhan Ramli",
  "alamat": "Jl. Kuin Utara No. 5",
  "kota": "Banjarmasin",
  "kode_pos": "70123",
  "email": "fadli.new@gymfit.com",
  "no_hp": "081234567890"
}

```

* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Data profil member berhasil diperbarui.",
  "data": {
    "id": 1,
    "id_member": "GYM-0001",
    "nama_lengkap": "M. Fadli Ramadhan Ramli",
    "alamat": "Jl. Kuin Utara No. 5",
    "kota": "Banjarmasin",
    "kode_pos": "70123",
    "email": "fadli.new@gymfit.com",
    "no_hp": "081234567890"
  }
}

```

---

### 8. Hapus Member (Hard Delete)

Menghapus data keanggotaan member secara permanen dari basis data fisik MySQL berdasarkan ID komponen.

* **URL:** `/members/{id}` (Contoh: `/members/1`)
* **Metode:** `DELETE`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Data keanggotaan member berhasil dihapus dari sistem secara permanen."
}

```

---

### 9. Logout Admin

Menghancurkan token keamanan yang dibawa pada sesi perangkat aktif guna mengamankan akses akun.

* **URL:** `/logout`
* **Metode:** `POST`
* **Respons Sukses (200 OK):**

```json
{
  "success": true,
  "message": "Sesi berhasil diakhiri. Token akses telah dihapus."
}

```

---

## 🚫 Respons Error Umum (Global Error Handling)

Standardisasi respons error yang dikembalikan oleh sistem apabila terjadi kendala di luar alur normal:

### 1. Error Validasi Input (422 Unprocessable Content)

```json
{
  "message": "Kolom nama lengkap wajib diisi. (and 1 more error)",
  "errors": {
    "nama_lengkap": ["Kolom nama lengkap wajib diisi."],
    "email": ["Format email tidak valid."]
  }
}

```

### 2. Error Autentikasi / Token Mati (401 Unauthorized)

```json
{
  "success": false,
  "message": "Unauthenticated."
}

```

### 3. Data Tidak Ditemukan (404 Not Found)

```json
{
  "success": false,
  "message": "Data member tidak ditemukan atau sudah dihapus."
}

```

### 4. Kegagalan Server Internal (500 Internal Server Error)

```json
{
  "success": false,
  "message": "Terjadi kesalahan pada server internal."
}

```

---

## 📋 Daftar HTTP Status Code Referensi

| Status Code | Nama Status | Deskripsi Penggunaan Pada Sistem |
| --- | --- | --- |
| `200` | **OK** | Permintaan HTTP berhasil diproses dan mengembalikan data. |
| `201` | **Created** | Data entitas baru (seperti Member Baru) sukses disimpan ke database. |
| `401` | **Unauthorized** | Kredensial login salah atau *Bearer Token* tidak valid/habis masa aktifnya. |
| `404` | **Not Found** | ID member atau rute URL yang dicari tidak tersedia di server. |
| `422` | **Unprocessable Content** | Validasi gagal karena data yang dikirim oleh Flutter tidak memenuhi aturan backend. |
| `500` | **Internal Server Error** | Terjadi gangguan pada server database MySQL atau kesalahan sintaks internal Laravel. |

---
