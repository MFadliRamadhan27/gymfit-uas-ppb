# PRODUCT REQUIREMENTS DOCUMENT (PRD)

## GymFit – Sistem Informasi Manajemen Member Gym
**Dokumen Spesifikasi Kebutuhan Produk Pengelolaan Data Keanggotaan**

* **Versi Dokumen:** 5.0 (Final Enterprise Standard)
* **Tanggal:** 02 Juli 2026
* **Status:** Approved & Locked
* **Disusun oleh:** M. Fadli Ramadhan (Product Owner)

---

## 1. Latar Belakang
Pengelolaan data member pada sebagian besar pusat kebugaran (gym) masih dilakukan secara manual menggunakan formulir kertas atau spreadsheet sederhana. Pendekatan konvensional ini menyulitkan staf administrasi dalam mencatat, memperbarui, mencari, maupun mengarsipkan data member secara cepat dan akurat.

**GymFit – Sistem Informasi Manajemen Member Gym** hadir sebagai solusi digital terpusat yang memfasilitasi kebutuhan operasional harian admin gym. Sistem ini menjembatani pengelolaan data lewat platform web desktop maupun aplikasi mobile secara terintegrasi agar staf dapat bekerja secara fleksibel di meja resepsionis maupun saat memantau langsung area gym.

---

## 2. Tujuan
* Menyediakan platform manajemen keanggotaan terpusat yang aman, intuitif, dan bebas dari risiko kehilangan data akibat kelalaian operasional.
* Menyajikan ringkasan informasi performa bisnis (statistik member) secara instan kepada pengelola saat pertama kali membuka sistem.
* Memastikan akurasi dan keselarasan pengembangan sistem melalui pemetaan kebutuhan pengguna yang terukur dan dapat diuji secara transparan.

---

## 3. Prioritas Fitur (MoSCoW Method)

| Kategori | Deskripsi | Fitur / Modul |
| :--- | :--- | :--- |
| **Must Have** | Wajib ada untuk operasional minimum | * Autentikasi Login/Logout Admin<br>* Manajemen Data Member (Tambah, Edit, Detail)<br>* Fitur Pencarian & Filter Member<br>* Sistem Pembagian Halaman (Pagination) |
| **Should Have** | Sangat penting, memiliki nilai guna tinggi | * Dashboard Ringkasan Statistik<br>* Mekanisme Proteksi Penghapusan (*Soft Delete*) |
| **Could Have** | Aksesori fungsional jika waktu pengerjaan sisa | * Fitur Ekspor Data Member ke Excel/PDF<br>* Opsi Mode Gelap (*Dark Mode*) pada Aplikasi Mobile |
| **Won't Have** | Ditunda penuh untuk pengembangan Fase 2 | * Sistem Absensi Mandiri (Scan QR Code)<br>* Pembayaran Iuran & Paket Membership |

---

## 4. Ruang Lingkup Detail Modul Dashboard
Halaman Dashboard dirancang sebagai pusat informasi visual ringkas mengenai kondisi keanggotaan gym saat ini dengan ketentuan perilaku data sebagai berikut:

* **Widget Total Member:** Menampilkan akumulasi angka dari seluruh jumlah member yang berstatus aktif di dalam sistem.
* **Widget Member Baru Bulan Ini:** Menampilkan jumlah member baru yang melakukan registrasi pada bulan kalender berjalan.
* **Daftar Member Terbaru:** Menampilkan tabel/list interaktif yang berisi 5 data member terakhir yang baru saja dimasukkan ke dalam sistem.
* **Aksi Cepat (Quick Action):** Menyediakan tombol pintas (*shortcut*) yang langsung mengarahkan Admin ke halaman Form Tambah Member.
* **Kondisi Data Kosong (Empty State Handling):** Jika sistem belum memiliki data member sama sekali (data berjumlah 0), panel daftar member terbaru wajib menyembunyikan tabel kosong dan menggantinya dengan tampilan teks panduan: *"Belum ada data member tercatat. Silakan klik tombol 'Tambah Member Baru' untuk memulai operasional."*

---

## 5. Alur Fungsional Sistem (Functional Flow)

### 5.1 Alur Pendaftaran Member Baru
```text
[Admin Login] ➔ [Masuk Dashboard] ➔ [Klik Shortcut Tambah] ➔ [Isi Form Isian]
                                                                     │
                                                                     ▼
[Pesan Sukses] ◄─── [Simpan ke Sistem] ◄─── [Lolos Validasi] ◄─── [Validasi Sistem]

```

### 5.2 Alur Pencarian & Modifikasi Data

```text
[Masuk Menu Member] ➔ [Ketik di Kolom Cari] ➔ [Sistem Memfilter List] ➔ [Klik Detail]
                                                                             │
       ┌─────────────────────────────── Batalkan Aksi ───────────────────────┤
       ▼                                                                     ▼
[Kembali ke List]   [Klik Hapus] ➔ [Konfirmasi Peringatan] ➔ [Sembunyikan dari List Aktif]

```

---

## 6. Kebutuhan Layar & Komponen Antarmuka (Screen Requirements)

### 6.1 Layar Dashboard

* **Komponen Atas:** Header aplikasi, Nama Admin aktif, dan Tombol Keluar (*Logout*).
* **Komponen Tengah:** Kartu Informasi (*Card Metric*) untuk Total Member dan Member Baru Bulan Ini.
* **Komponen Aksi:** Tombol Pintas (*Shortcut Floating Button*) bertuliskan "Tambah Member Baru".
* **Komponen Bawah:** Panel daftar pendek (*Recent Activity*) menampilkan 5 member terbaru atau teks *Empty State* jika data kosong.

### 6.2 Layar Daftar Member (List Member)

* **Komponen Pencarian:** Kotak teks filter (*Search Bar*) dengan penanda teks bawaan (*placeholder*).
* **Komponen Utama:** Kartu list/tabel yang menampilkan ID Member, Nama Lengkap, dan Kota Domisili.
* **Komponen Navigasi:** Tombol navigasi halaman (*Next, Previous, Page Number*).
* **Komponen Kontrol:** Tombol akses cepat menuju halaman Detail dan Form Edit di setiap baris member.

---

## 7. User Stories (Agile Standard)

* **US-01 (Login):** **As an** Admin, **I want to** log in to the system using registered credentials, **So that** I can securely access sensitive gym membership data.
* **US-02 (Dashboard):** **As an** Admin, **I want to** view a summary dashboard upon logging in, **So that** I can instantly monitor operational trends without opening separate reports.
* **US-03 (Daftar Member):** **As an** Admin, **I want to** view a paginated list of all members, **So that** the application interface remains clean and responsive even with large volumes of data.
* **US-04 (Tambah Member):** **As an** Admin, **I want to** register a new gym member via a digital form, **So that** customer information is recorded centrally in the system.
* **US-05 (Edit Member):** **As an** Admin, **I want to** modify a member's profile data, **So that** typos or updates to their contact details can be corrected.
* **US-06 (Detail Member):** **As an** Admin, **I want to** view the complete profile details of an individual member, **So that** I can verify their detailed address and information.
* **US-07 (Hapus Member):** **As an** Admin, **I want to** delete an inactive member's data, **So that** the member directory remains clean and up to date.
* **US-08 (Pencarian):** **As an** Admin, **I want to** search for a member by typing their name or ID, **So that** I can retrieve customer info at the reception desk within seconds.
* **US-09 (Logout):** **As an** Admin, **I want to** log out of the application after my shift, **So that** my account cannot be misused by unauthorized staff.

---

## 8. Matriks Keterlacakan Kebutuhan (Requirement Traceability Matrix - RTM)

Matriks ini memastikan setiap skenario kebutuhan pengguna (*User Story*) memiliki implementasi fungsional (*Functional Requirement*) yang jelas dan dapat diuji:

| User Story ID | Functional Requirement ID | Deskripsi Keterkaitan Kebutuhan |
| --- | --- | --- |
| **US-01** | FR-01 | Sistem menangani otentikasi akun masuk Admin. |
| **US-02** | FR-03, FR-04 | Layar Dashboard menyajikan visualisasi metrik data & tombol cepat. |
| **US-03** | FR-11 | Penyajian list member didukung oleh sistem pembagian halaman. |
| **US-04** | FR-05, FR-06 | Pengisian form registrasi baru dikawal oleh validasi ketat sistem. |
| **US-05** | FR-07 | Perubahan data diperbarui langsung ke dalam sistem penyimpanan. |
| **US-06** | FR-08 | Tampilan detail menyajikan seluruh atribut kamus data secara utuh. |
| **US-07** | FR-09 | Penghapusan data diisolasi menggunakan mekanisme pengamanan logis. |
| **US-08** | FR-10 | Penyaringan list data bekerja responsif lewat kata kunci multi-parameter. |
| **US-09** | FR-02 | Aksi keluar langsung menghancurkan hak akses token aktif tamu. |

---

## 9. Kebutuhan Fungsional & Kriteria Penerimaan (Acceptance Criteria)

| ID | Modul | Kebutuhan Fungsional | Acceptance Criteria (Kriteria Penerimaan) |
| --- | --- | --- | --- |
| **FR-01** | Auth | Autentikasi Akun Admin | **Given:** Admin berada di layar login.<br>

<br>**When:** Admin memasukkan kombinasi email/password yang keliru.<br>

<br>**Then:** Sistem menolak akses masuk, mengosongkan kolom sandi, dan menampilkan pesan kesalahan: *"Email atau password salah."* |
| **FR-02** | Auth | Proteksi Akses Tamu | **Given:** Pengguna belum melakukan proses login.<br>

<br>**When:** Pengguna mencoba mengakses tautan halaman internal secara langsung.<br>

<br>**Then:** Sistem memblokir tindakan tersebut dan mengalihkan paksa pengguna ke layar Login. |
| **FR-03** | Dash | Akurasi Metrik Data | **Given:** Admin berada di layar Dashboard utama.<br>

<br>**When:** Halaman selesai dimuat.<br>

<br>**Then:** Angka statistik wajib sinkron dengan total riil data di server, dan daftar aktivitas terbaru menampilkan maksimal 5 baris data teranyar. |
| **FR-04** | Dash | Pintasan Aksi Cepat | **Given:** Admin berada di layar Dashboard utama.<br>

<br>**When:** Menekan tombol pintas tambah member.<br>

<br>**Then:** Sistem langsung memindahkan layar pengguna menuju halaman Form Tambah Member. |
| **FR-05** | Member | Pendaftaran Member | **Given:** Admin berada di Form Tambah Member.<br>

<br>**When:** Seluruh bidang isian diisi secara lengkap dan valid lalu menekan tombol Simpan.<br>

<br>**Then:** Sistem menyimpan data, memicu pesan sukses, dan mengarahkan Admin ke daftar utama. |
| **FR-06** | Member | Validasi Keunikan Isian | **Given:** Admin menginput nilai Email atau ID Member yang sudah terdaftar di sistem.<br>

<br>**When:** Tombol Simpan ditekan.<br>

<br>**Then:** Proses simpan dibatalkan, sistem mempertahankan teks isian form lainnya, dan memberi penanda merah disertai pesan: *"ID Member/Email sudah digunakan."* |
| **FR-07** | Member | Perubahan Data (Edit) | **Given:** Admin membuka form modifikasi profil member.<br>

<br>**When:** Mengubah data bidang pilihan dan menekan tombol Simpan Perubahan.<br>

<br>**Then:** Data profil langsung terbarui di sistem dan Admin menerima konfirmasi keberhasilan. |
| **FR-08** | Member | Tampilan Rincian Data | **Given:** Admin memilih salah satu nama member di daftar utama.<br>

<br>**When:** Menekan tombol Detail.<br>

<br>**Then:** Sistem menyajikan lembar informasi lengkap yang menampilkan seluruh atribut data member secara terperinci. |
| **FR-09** | Member | Penghapusan Logis | **Given:** Admin menekan opsi Hapus pada baris member aktif.<br>

<br>**When:** Admin menyetujui kotak dialog konfirmasi peringatan hapus.<br>

<br>**Then:** Member tersebut seketika hilang dari daftar aktif utama dan perhitungan dashboard, namun dokumen fisiknya di server aman (tidak musnah permanen). |
| **FR-10** | Member | Filter Pencarian Instan | **Given:** Admin mengetikkan karakter pada kotak pencarian.<br>

<br>**When:** Kotak cari terisi teks kata kunci.<br>

<br>**Then:** Daftar baris otomatis menyusut secara dinamis hanya menampilkan member yang memiliki kesamaan nilai pada atribut Nama, ID, atau Kota. |
| **FR-11** | Member | Pembagian Halaman | **Given:** Total rekaman data member di dalam sistem berjumlah lebih dari 10 data.<br>

<br>**When:** Admin membuka daftar member utama.<br>

<br>**Then:** Sistem memecah tampilan list menjadi beberapa halaman teratur dengan batasan maksimal 10 data per halaman. |
| **FR-12** | Auth | Pemutusan Sesi (Logout) | **Given:** Admin menekan tombol keluar aplikasi.<br>

<br>**When:** Tombol Logout dikonfirmasi.<br>

<br>**Then:** Sesi hak akses Admin dinyatakan hangus secara permanen dan sistem mengunci kembali layar ke halaman Login. |

---

## 10. Kamus Data & Batasan Aturan (Data Dictionary & Constraints)

| Nama Bidang (Field) | Format Data | Sifat Aturan (Constraints) | Keterangan Bisnis |
| --- | --- | --- | --- |
| **ID Member** | Teks Berpola | Wajib diisi, Bersifat Unik, Maksimal 20 karakter. Contoh format: **M001**, **M002** | Kode unik identitas fisik kartu member. |
| **Nama Lengkap** | Teks Alfabet | Wajib diisi, Maksimal 100 karakter, Tidak boleh mengandung karakter angka atau simbol. | Nama lengkap pelanggan sesuai KTP. |
| **Alamat** | Teks Panjang | Wajib diisi, Bebas format karakter teks. | Alamat lokasi rumah tinggal member. |
| **Kota** | Teks Pendek | Wajib diisi, Maksimal 50 karakter. | Kota domisili tinggal saat ini. |
| **Kode Pos** | Angka Murni | Wajib diisi, Harus berupa angka numerik, Maksimal 5 digit. | Kode wilayah pos domisili. |
| **Email** | Format Surel | Wajib diisi, Bersifat Unik, Maksimal 100 karakter, Wajib menyertakan simbol `@` dan akhiran domain valid. | Alamat surat elektronik aktif pelanggan. |
| **No HP** | Angka Murni | Wajib diisi, Harus berupa angka numerik diawali angka `08`, Panjang karakter berkisar 10-15 digit. | Nomor kontak seluler/WhatsApp aktif. |

---

## 11. Aturan Bisnis Manajemen Status Data (Soft Delete)

Sistem **GymFit** wajib mengadopsi aturan penanganan data terhapus dengan ketentuan logika bisnis berikut:

1. Data member yang dikenakan aksi hapus oleh Admin **tidak boleh dimusnahkan secara fisik** dari pusat penyimpanan data.
2. Status internal data akan diubah menjadi *"Ditangguhkan/Terhapus secara Logis"*.
3. **Efek Langsung pada Aplikasi:** Data tersebut otomatis dikucilkan dari seluruh fungsi pencarian, daftar tabel aktif, dan kalkulasi widget dashboard.
4. **Tujuan:** Melindungi operasional gym dari aksi sabotase staf atau ketidaksengajaan klik, sekaligus membuka peluang bagi pihak manajemen untuk mengaktifkan kembali data tersebut di masa depan (`restore`) jika member memutuskan bergabung kembali.

---

## 12. Batasan Integrasi REST API (High-Level Policy)

* **Arsitektur Utama:** Pertukaran data antara aplikasi mobile dan sistem pusat wajib menggunakan format pesan terstandardisasi (JSON).
* **Kebijakan Sesi Keamanan:** Semua jalur data operasional member bersifat rahasia. Akses data hanya diberikan jika aplikasi mobile menyertakan kunci autentikasi digital (*Bearer Token*) yang sah pada tiap permintaan data.
* **Terminasi Sesi:** Kunci akses digital wajib dihancurkan dan tidak dapat digunakan kembali seketika setelah Admin menekan tombol keluar (*Logout*) pada perangkat.

---

## 13. Sketsa Tata Letak Layar (Conceptual Screen Sketch)

### 13.1 Sketsa Tata Letak Dashboard Utama (Aplikasi Mobile)

```text
+---------------------------------------+
|  GymFit – Dashboard        [Logout]   |
+---------------------------------------+
|  Selamat Datang, Admin Ramadhan!      |
|                                       |
|  +-----------------+ +-------------+  |
|  | Total Member    | | Member Baru |  |
|  |   120 Member    | |   15 User   |  |
|  +-----------------+ +-------------+  |
|                                       |
|  [+] DAFTARKAN MEMBER BARU            |  <--- Shortcut Action Button
|                                       |
|  Aktivitas Pendaftaran Terbaru:       |
|  -----------------------------------  |
|  * M005 - Fahra Ragita    (Bandung)   |
|  * M004 - M. Fadli R.     (Banjarmasin|
|  * M003 - Ahmad Arifin    (Banjarbaru)|
|  -----------------------------------  |
|  [ Buka Seluruh Daftar Member ]       |
+---------------------------------------+

```

### 13.2 Sketsa Tata Letak Daftar Data Member (Aplikasi Mobile)

```text
+---------------------------------------+
|  GymFit – Daftar Member               |
+---------------------------------------+
|  [ Cari nama / ID / kota...       ]   |  <--- Multi-parameter Search
|  -----------------------------------  |
|  ID Member : M001                     |
|  Nama      : FAHRA RAGITA             |
|  Kota      : Bandung                  |
|  Aksi      : [ Detail ] [ Edit ]      |
|  -----------------------------------  |
|  ID Member : M002                     |
|  Nama      : M. FADLI RAMADHAN        |
|  Kota      : Banjarmasin              |
|  Aksi      : [ Detail ] [ Edit ]      |
|  -----------------------------------  |
|  Halaman   : <  [1]  2  3  >          |  <--- Pagination Control
+---------------------------------------+

```

---

## 14. Kebutuhan Non-Fungsional (Non-Functional Requirements)

### 14.1 Kinerja (Performance)

* Layanan penampilan data halaman Dashboard dan List Member wajib termuat penuh dalam waktu maksimal **3 detik** pada kondisi koneksi jaringan standar.

### 14.2 Keamanan (Security)

* Sistem wajib mengamankan kata sandi pengguna menggunakan metode pengacakan satu arah (*secure hashing*) sebelum disimpan ke basis data.
* Sistem harus menerapkan batasan waktu sesi aktif (*session timeout*). Jika aplikasi tidak mendeteksi adanya aktivitas operasional selama jangka waktu yang ditentukan, akses akan otomatis dikunci demi keamanan data.

### 14.3 Kompatibilitas (Compatibility)

* Antarmuka sistem web admin wajib responsif dan dapat diakses dengan normal melalui peramban desktop populer (Chrome, Edge, Safari).
* Aplikasi mobile wajib mendukung performa stabil saat dijalankan pada sistem operasi Android maupun iOS.

### 14.4 Ketersediaan & Cadangan (Availability & Backup)

* Pusat penyimpanan data wajib dikonfigurasi untuk melakukan pencadangan (*automated backup*) secara berkala untuk meminimalisir risiko kehilangan data akibat gangguan perangkat keras.

### 14.5 Aksesibilitas (Accessibility)

* Seluruh teks panduan operasional dan label isian pada aplikasi wajib menggunakan ukuran font minimal **14 px** untuk menjamin kenyamanan keterbacaan mata staf admin saat bekerja.

---

## 15. Target Kinerja & Ukuran Keberhasilan (KPIs)

* **Target Ketersediaan Sistem (Uptime Target):** Tingkat ketersediaan operasional sistem ditargetkan mencapai angka **99%** selama jam operasional gym berjalan.
* **Toleransi Keberhasilan API:** Tingkat keberhasilan transaksi pertukaran data antara aplikasi genggam dan server pusat wajib menyentuh batas minimal **95%** sukses.
* **Kecepatan Respons Penyaringan:** Durasi pemrosesan pemfilteran baris data pada fungsi pencarian member wajib selesai dalam waktu **kurang dari 2 detik** saat diuji menggunakan ribuan data simulasi.

---

## 16. Pengembangan Masa Depan (Future Enhancement - Fase 2)

* **Sistem Check-in Digital:** Konversi otomatis string `id_member` menjadi tampilan grafik QR Code siap pindai di aplikasi mobile.
* **Otomatisasi Laporan:** Modul eksportasi satu-klik ke format file spreadsheet Excel (`.xlsx`) dan dokumen cetak resmi PDF untuk pelaporan berkala pemilik usaha gym.