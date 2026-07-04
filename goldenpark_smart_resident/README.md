# GoldenPark Smart Resident

Aplikasi Flutter untuk manajemen resident Golden Park Serpong. Fitur utama:

- Firebase Authentication untuk login, register, dan logout.
- CRUD resident melalui REST API Laravel.
- Dashboard resident dan peta area menggunakan OpenStreetMap.

## Menjalankan Aplikasi

Install dependency:

```sh
flutter pub get
```

Jalankan dengan API default lokal. Di web, default API adalah `http://127.0.0.1:8000/api`; di Android, default API adalah `http://192.168.100.73:8000/api`.

```sh
flutter run
```

Atau tentukan base URL API sendiri:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.100.73:8000/api
```

Untuk web/Chrome saat Laravel berjalan di komputer yang sama:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Jika backend Laravel sudah memvalidasi Firebase ID token, aktifkan pengiriman bearer token:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api --dart-define=API_SEND_AUTH=true
```

Catatan untuk Flutter web: Laravel harus mengizinkan CORS dari origin Chrome Flutter, misalnya `http://localhost:*`, serta method `GET, POST, PUT, DELETE` dan header `Accept, Content-Type, Authorization`.

Untuk production, gunakan endpoint HTTPS dan sesuaikan konfigurasi signing Android.

## Verifikasi

```sh
flutter analyze
flutter test
```
