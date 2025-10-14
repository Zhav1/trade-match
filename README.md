# TradeMatch

**Deskripsi Singkat:**  
TradeMatch adalah aplikasi barter modern yang memungkinkan pengguna untuk saling menukar barang dengan cara yang efisien, aman, dan menyenangkan. Aplikasi ini menggabungkan konsep “match system” layaknya aplikasi dating untuk menemukan pasangan barter yang cocok berdasarkan kebutuhan dan penawaran pengguna.

---

## 👥 Anggota Kelompok
| Nama | NIM |
|------|-----|
| Qhanakin Ahmad Zhavi | 231402071 |
| Firman Karunia Naibaho | 231402074 |
| Alfathin suwailim | 231402096 |
| Muhammad Ilyas Hasibuan | 231402106 |
| Rifki Reysaad Bangun | 231402109 |

---

## 🚀 Rencana Fitur Aplikasi

### 1. Profile
Berisi informasi dasar pengguna seperti nama, lokasi, foto, dan deskripsi singkat.  
Menampilkan daftar barang yang ditawarkan (offer) dan dibutuhkan (requirement).  
Pengguna dapat mengedit profil, menambah atau menghapus barang, serta memperbarui status barter.

### 2. Library
Berfungsi sebagai “gudang pribadi” pengguna.  
Menampilkan semua barang yang dimiliki, baik yang aktif, sudah dibarter, maupun disimpan.  
Pengguna dapat mengatur ulang barang, menandai statusnya (“aktif”, “terbuka untuk barter”, “selesai”), atau menghapus item.

### 3. Beranda (Home & Explore)
Halaman utama tempat pengguna menemukan dan menjelajahi barang milik pengguna lain.  
Fitur ini menggabungkan fungsi *explore* dan *swipe system* layaknya aplikasi dating untuk menemukan pasangan barter yang cocok.

Fitur utama di halaman ini:
- **Swipe Kanan →** tertarik barter  
- **Swipe Kiri →** lewati  
- **Match System:** jika kedua pengguna sama-sama tertarik, maka akan terjadi *match* dan fitur chat akan terbuka.  
- **Rekomendasi Barang:** menampilkan barang baru di sekitar lokasi pengguna atau sesuai kategori favorit.  
- **Aktivitas Komunitas:** notifikasi match baru dan barter yang berhasil.  

Halaman ini juga dapat menampilkan **update barang terbaru**, **notifikasi**, serta **rekomendasi personal** berdasarkan riwayat barter pengguna.

### 4. Chat
Fitur **Chat** memungkinkan pengguna berkomunikasi langsung setelah terjadi *match* antara dua pengguna.  
Tujuannya untuk memudahkan negosiasi dan memastikan kesepakatan barter berjalan lancar.  

Fitur yang tersedia di dalam Chat:
- **Pesan Teks:** pengguna bisa saling mengirim pesan untuk mendiskusikan detail barter.  
- **Kirim Foto:** pengguna dapat mengirim foto barang tambahan atau kondisi terbaru barang.  
- **Notifikasi Pesan Baru:** agar pengguna tidak melewatkan percakapan penting.  
- **Penghapusan Chat:** pengguna dapat menghapus percakapan jika barter sudah selesai atau tidak dilanjutkan.  

Chat menjadi jembatan penting sebelum melangkah ke fitur **Janji Temu**, karena semua kesepakatan mengenai pertukaran barang biasanya dilakukan di tahap ini.

### 5. Janji Temu (Meet-Up)
Fitur pengaturan pertemuan setelah barter disepakati.  
Pengguna dapat menentukan tanggal, waktu, dan lokasi pertemuan.  
Tersedia pengingat (reminder) serta integrasi dengan *maps* untuk melihat rute ke lokasi barter.

### 6. Search
Membantu pengguna mencari barang berdasarkan:
- Nama atau kategori (misalnya “buku”, “elektronik”)  
- Lokasi (radius tertentu)  
- Kebutuhan spesifik (“butuh laptop bekas”)  

---

## 🧠 Deskripsi Project

- **Jenis Aplikasi:** Cross Platform  
- **Frontend Framework:** Flutter  
- **Backend Framework:** Laravel 11  
- **Autentikasi API:** Laravel Sanctum  
- **Bahasa Pemrograman Backend:** PHP  
- **Database:** MySQL  
- **Versi SDK Flutter:** 3.35.2
- **IDE yang Digunakan:** Android Studio / VS Code / PHPStorm  
- **Target Platform:** Android dan iOS  

---

## 🔗 Arsitektur Singkat

TradeMatch menggunakan arsitektur **client-server**:
- **Frontend (Flutter)** berfungsi sebagai aplikasi utama yang digunakan pengguna untuk menampilkan data dan berinteraksi.  
- **Backend (Laravel)** bertugas menangani logika bisnis, autentikasi pengguna dengan **Sanctum**, serta penyimpanan data di **MySQL Database**.  
- Komunikasi antara frontend dan backend dilakukan melalui **RESTful API** dengan format **JSON**.

---

## 🎨 Implementasi Layout Dasar (3 Halaman)

1. **Halaman Beranda (Home):** menampilkan barang terbaru dan rekomendasi barter.  
2. **Halaman Explore (Swipe):** tempat pengguna menemukan potensi barter dengan sistem *match*.  
3. **Halaman Profil (Profile):** menampilkan identitas dan daftar barang pengguna.  

> Layout ini merupakan dasar tampilan utama yang akan dikembangkan lebih lanjut menjadi aplikasi barter interaktif.

---

## 📚 Kesimpulan

TradeMatch membentuk ekosistem barter digital yang efisien dan menyenangkan.  
Dengan fitur-fitur yang terintegrasi (Profile, Library, Swipe, Chat, dan Meet-Up), pengguna dapat menemukan pasangan barter yang cocok dan melakukan pertukaran barang secara aman dan transparan.

---
