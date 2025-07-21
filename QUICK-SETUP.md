# Quick Setup VPS - Deploy Laravel (Bahasa Indonesia)

[English Version](QUICK-SETUP-EN.md)

[![Laravel](https://img.shields.io/badge/Laravel-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-purple.svg)](https://php.net)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Prasyarat
- VPS Ubuntu/Debian
- Domain sudah mengarah ke IP VPS
- Akses root/sudo
- Git terinstal
- Repository Git dengan proyek Laravel yang valid

## Fitur
- Instalasi otomatis semua software yang diperlukan (PHP, PostgreSQL, Nginx, Certbot)
- Setup database otomatis dengan password yang aman
- Deteksi branch pintar (mencoba main/master/pupuk secara berurutan)
- Konfigurasi environment yang aman
- Setup sertifikat SSL dengan Let's Encrypt
- Pengaturan permission file yang tepat
- Setup autentikasi Laravel Shield (opsional)
- Optimasi performa secara otomatis

## Setup Otomatis (Direkomendasikan)

Gunakan script deployment generik berikut untuk berbagai repo Laravel:

```bash
wget https://raw.githubusercontent.com/IlhamGhaza/laravel-pos/pupuk/deploy-laravel/deploy-laravel.sh
chmod +x deploy-laravel.sh
sudo ./deploy-laravel.sh <repo_url> [branch] <domain> <email>
```

**Contoh penggunaan:**

- Dengan branch spesifik:
  ```bash
  sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git main mydomain.com admin@mydomain.com
  ```
- Tanpa branch (akan dicoba main/master/pupuk):
  ```bash
  sudo ./deploy-laravel.sh https://github.com/laravel/laravel.git mydomain.com admin@mydomain.com
  ```

**Keterangan argumen:**
- `<repo_url>`: Link repository Laravel (wajib)
- `[branch]`: Nama branch (opsional)
- `<domain>`: Domain aplikasi (wajib)
- `<email>`: Email untuk notifikasi SSL (wajib)

Script akan otomatis melakukan:

- Instalasi semua software yang dibutuhkan:
  - PHP dengan ekstensi yang diperlukan
  - Database PostgreSQL
  - Web server Nginx
  - Certbot untuk SSL
  - Composer untuk dependency PHP

- Setup proyek:
  - Clone repo Laravel ke `/var/www/<nama_repo>`
  - Membuat database dan user PostgreSQL dengan password aman
  - Mengkonfigurasi variable environment
  - Mengatur permission file
  - Menginstal dependency Composer
  - Menjalankan migrasi dan seeder Laravel
  - Setup autentikasi Laravel Shield (jika diperlukan)
  - Konfigurasi Nginx dengan pengaturan optimal
  - Instalasi sertifikat SSL

- Optimasi untuk production:
  - Cache konfigurasi
  - Cache route
  - Cache view
  - Membuat link storage
  - Mengatur permission file yang aman
  - Konfigurasi pengaturan environment production

## Detail Setup Database

Script akan:
1. Membuat database bernama `laravel_pos`
2. Membuat user bernama `laravel_pos_app`
3. Generate password yang aman secara random
4. Memberikan permission yang diperlukan
5. Menyimpan kredensial di file `.env`

## Fitur Keamanan

- Sertifikat SSL via Let's Encrypt
- Permission file yang aman
- Pengaturan environment production
- Mode debug dinonaktifkan
- Header keamanan Nginx
- Rate limiting untuk endpoint API
- Proteksi file sistem
- Kredensial database yang aman

## Setup Manual (Opsional)

Jika Anda lebih memilih setup manual, ikuti langkah-langkah berikut:

1. **Instalasi Software**
   - PHP 8.x dan ekstensi: pgsql, zip, gd, mbstring, curl, xml, bcmath, intl
   - Composer (versi terbaru)
   - Database PostgreSQL
   - Web server Nginx
   - Certbot untuk SSL

2. **Konfigurasi PostgreSQL**
   - Buat database dan user
   - Set password yang aman
   - Berikan permission yang diperlukan

3. **Setup Proyek**
   - Clone repo ke `/var/www/<nama_repo>`
   - Set kepemilikan ke: `www-data:www-data`
   - Set permission direktori: 755
   - Set permission storage/cache: 777

4. **Konfigurasi Laravel**
   - Copy `.env.example` ke `.env`
   - Konfigurasi koneksi database
   - Set environment production
   - Generate kunci aplikasi
   - Install dependency
   - Jalankan migrasi dan seeder

---

## Troubleshooting & Perintah Penting

### Manajemen Service

Cek status service:
```bash
sudo systemctl status nginx php-fpm postgresql
```

Restart service:
```bash
sudo systemctl restart nginx php-fpm postgresql
```

### File Log

Lihat log error Nginx:
```bash
sudo tail -f /var/log/nginx/error.log
```

Lihat log aplikasi Laravel:
```bash
sudo tail -f /var/www/<nama_repo>/storage/logs/laravel.log
```

### Masalah Umum

1. **Masalah Permission**
   ```bash
   sudo chown -R www-data:www-data /var/www/<nama_repo>
   sudo chmod -R 755 /var/www/<nama_repo>
   sudo chmod -R 777 /var/www/<nama_repo>/storage
   sudo chmod -R 777 /var/www/<nama_repo>/bootstrap/cache
   ```

2. **Masalah Sertifikat SSL**
   ```bash
   sudo certbot --nginx -d domain-anda.com
   sudo certbot renew --dry-run
   ```

3. **Koneksi Database**
   ```bash
   sudo -u postgres psql -c "\l"  # Daftar database
   sudo -u postgres psql -c "\du"  # Daftar user
   ```

4. **Konfigurasi Nginx**
   ```bash
   sudo nginx -t  # Test konfigurasi
   sudo systemctl reload nginx  # Reload konfigurasi
   ```

## Konfigurasi Environment

File `.env` Anda akan dikonfigurasi dengan:

```env
# Pengaturan Aplikasi
APP_ENV=production
APP_DEBUG=false
APP_URL=https://<domain>

# Konfigurasi Database
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=laravel_pos
DB_USERNAME=laravel_pos_app
DB_PASSWORD=<password_aman_auto_generate>

# Pengaturan Performa
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Header Keamanan
SESSION_SECURE_COOKIE=true
SESSION_COOKIE_HTTPONLY=true
SESSION_DRIVER=file
QUEUE_CONNECTION=sync
```

---

Untuk detail lebih lanjut, cek README atau dokumentasi repo Anda. 
