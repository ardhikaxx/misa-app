# RULE-MISA.md
## Blueprint Arsitektur Sistem — MISA (Mobile Invoice & Service Application)

---

## 1. Ringkasan Aplikasi

**MISA (Mobile Invoice & Service Application)** adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pelaku UMKM di bidang jasa mengelola operasional usahanya secara digital — mulai dari pencatatan layanan, data pelanggan, transaksi, hingga pembuatan invoice PDF profesional dan laporan pendapatan.

**Masalah yang diselesaikan:**
- Pencatatan transaksi manual via buku atau chat WhatsApp yang rawan hilang dan sulit direkap.
- Tidak adanya invoice profesional untuk dikirim ke pelanggan.
- Tidak ada riwayat pelanggan yang terstruktur.
- Pemilik usaha kesulitan memantau pendapatan dan status pekerjaan yang sedang berjalan.

**Target pengguna:** pelaku UMKM jasa seperti servis AC, salon, laundry, fotografi, desain grafis, percetakan, servis elektronik, bengkel, catering, dan jasa digital.

**Value proposition utama:** *"Dari transaksi jadi invoice PDF dalam hitungan detik, langsung dari HP."*

---

## 2. Prinsip Arsitektur: Single-Tenant per Akun

MISA menggunakan model **single-tenant**, di mana **satu akun Firebase Authentication = satu UMKM jasa**.

- Saat pengguna mendaftar (email/password atau Google Sign-In), sistem otomatis membuat satu dokumen usaha di koleksi `businesses` dengan **document ID = Firebase `uid`**.
- Seluruh data anak (layanan, pelanggan, transaksi, invoice, pengaturan) berada sebagai **subkoleksi** di bawah dokumen usaha tersebut.
- Tidak ada konsep multi-user dalam satu usaha pada versi awal (MVP) — setiap uid terisolasi penuh secara data maupun akses.
- Keuntungan: struktur data sederhana, security rules mudah diverifikasi (`request.auth.uid == businessId`), tidak ada risiko data bocor antar UMKM, query selalu di-scope ke satu usaha sehingga performa tetap ringan meski jumlah pengguna aplikasi bertambah banyak.

> Catatan pengembangan jangka panjang: jika di masa depan dibutuhkan multi-staff per usaha (misal owner + admin/kasir), maka ditambahkan subkoleksi `businesses/{uid}/members` dengan role-based access — tapi ini di luar cakupan MVP dan tidak mengubah struktur inti.

---

## 3. Tech Stack

| Layer | Teknologi | Catatan |
|---|---|---|
| Framework | Flutter (stable channel) | Target Android prioritas utama, iOS menyusul |
| Bahasa | Dart | Null-safety wajib |
| State Management | **Riverpod** (`flutter_riverpod` + `riverpod_annotation`) | Konsisten dengan stack proyek-proyek sebelumnya |
| Routing | **go_router** | Declarative routing, redirect guard untuk auth |
| Backend as a Service | **Firebase** | Authentication, Firestore, Storage |
| Autentikasi | Firebase Authentication (Email/Password + Google Sign-In) | `google_sign_in` package |
| Database | Cloud Firestore | NoSQL, struktur bertingkat per business |
| File Storage | Firebase Storage | Logo usaha, arsip PDF invoice (opsional) |
| PDF Generator | `pdf` + `printing` | Generate & preview/print invoice |
| Berbagi File | `share_plus` | Kirim invoice ke WhatsApp/email |
| Local Path | `path_provider` | Simpan file PDF sementara di device |
| Format Angka/Tanggal | `intl` | Format Rupiah & tanggal Indonesia |
| Image Picker | `image_picker` | Upload logo usaha |
| Grafik Laporan | `fl_chart` | Visualisasi laporan pendapatan |
| Local Notification (opsional) | `flutter_local_notifications` | Reminder invoice jatuh tempo |
| Push Notification (future) | Firebase Cloud Messaging + Cloud Functions | Tidak wajib di MVP |
| Environment Config | `flutter_dotenv` atau `--dart-define` | Firebase config per environment |

**Package Firebase inti:**
```
firebase_core
firebase_auth
cloud_firestore
firebase_storage
google_sign_in
```

---

## 4. Struktur Folder Project (Flutter — Clean Architecture + Riverpod)

```
lib/
├── main.dart
├── app.dart                         # MaterialApp.router + ProviderScope
├── firebase_options.dart
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   ├── app_strings.dart         # Semua teks statis Bahasa Indonesia
│   │   └── firestore_paths.dart     # Konstanta path koleksi/subkoleksi
│   ├── utils/
│   │   ├── currency_formatter.dart  # Format Rupiah
│   │   ├── date_formatter.dart
│   │   ├── invoice_number_generator.dart
│   │   └── validators.dart          # Validasi form (Bahasa Indonesia)
│   ├── errors/
│   │   ├── app_exception.dart
│   │   └── failure.dart
│   └── theme/
│       └── app_theme.dart
│
├── models/
│   ├── business_model.dart
│   ├── service_model.dart
│   ├── customer_model.dart
│   ├── transaction_model.dart
│   ├── transaction_item_model.dart
│   ├── invoice_model.dart
│   └── job_status_model.dart
│
├── services/                        # Layer komunikasi Firebase
│   ├── auth_service.dart
│   ├── business_service.dart
│   ├── service_catalog_service.dart # CRUD layanan jasa
│   ├── customer_service.dart
│   ├── transaction_service.dart
│   ├── invoice_service.dart
│   ├── report_service.dart
│   ├── storage_service.dart         # Upload logo, PDF
│   └── pdf_generator_service.dart
│
├── providers/                       # Riverpod providers per fitur
│   ├── auth_provider.dart
│   ├── business_provider.dart
│   ├── service_catalog_provider.dart
│   ├── customer_provider.dart
│   ├── transaction_provider.dart
│   ├── invoice_provider.dart
│   ├── report_provider.dart
│   └── dashboard_provider.dart
│
├── routing/
│   ├── app_router.dart              # go_router konfigurasi + redirect guard
│   └── route_paths.dart
│
└── presentation/
    ├── splash/
    │   └── splash_screen.dart
    ├── auth/
    │   ├── login_screen.dart
    │   ├── register_screen.dart
    │   └── widgets/
    ├── onboarding/
    │   └── business_setup_screen.dart
    ├── dashboard/
    │   ├── dashboard_screen.dart
    │   └── widgets/
    │       ├── summary_card.dart
    │       └── recent_transaction_tile.dart
    ├── services/
    │   ├── service_list_screen.dart
    │   ├── service_form_screen.dart
    │   └── widgets/
    ├── customers/
    │   ├── customer_list_screen.dart
    │   ├── customer_form_screen.dart
    │   ├── customer_detail_screen.dart
    │   └── widgets/
    ├── transactions/
    │   ├── transaction_list_screen.dart
    │   ├── transaction_form_screen.dart
    │   ├── transaction_detail_screen.dart
    │   └── widgets/
    ├── invoices/
    │   ├── invoice_preview_screen.dart
    │   └── widgets/
    ├── reports/
    │   ├── report_screen.dart
    │   └── widgets/
    │       └── revenue_chart.dart
    └── settings/
        ├── settings_screen.dart
        ├── business_profile_screen.dart
        └── widgets/
```

**Aturan lapisan:**
- `presentation/` hanya boleh memanggil `providers/`, tidak boleh mengakses `services/` langsung.
- `providers/` mengatur state dan memanggil `services/`.
- `services/` satu-satunya layer yang berkomunikasi langsung dengan Firebase SDK.
- `models/` murni struktur data (immutable, dengan `fromMap`/`toMap` dan `fromFirestore`/`toFirestore`).

---

## 5. Struktur Database Firestore

### 5.1 Peta Koleksi

```
businesses (collection)
└── {uid} (document)
    ├── services (subcollection)
    │   └── {serviceId}
    ├── customers (subcollection)
    │   └── {customerId}
    ├── transactions (subcollection)
    │   └── {transactionId}
    └── settings (subcollection)
        └── general  (single document)
```

> **Catatan desain:** invoice **tidak disimpan sebagai koleksi terpisah**. Invoice adalah representasi/render dari sebuah dokumen `transaction` (1 transaksi = 1 invoice). Nomor invoice, status cetak, dan metadata invoice disimpan sebagai field di dalam dokumen transaksi itu sendiri. Ini menghindari duplikasi data dan menjaga single source of truth. Jika ke depan dibutuhkan riwayat pengiriman invoice (misal log "dikirim ulang ke WA 3x"), baru ditambahkan subkoleksi `transactions/{id}/invoiceLogs`.

### 5.2 `businesses/{uid}`

| Field | Tipe | Keterangan |
|---|---|---|
| `businessId` | string | Sama dengan `uid`, disimpan redundant untuk kemudahan query |
| `ownerName` | string | Nama pemilik |
| `businessName` | string | Nama UMKM |
| `businessCategory` | string | Kategori jasa (servis AC, salon, dll) |
| `address` | string | Alamat usaha |
| `whatsappNumber` | string | Nomor WA untuk kontak di invoice |
| `email` | string | Email akun |
| `logoUrl` | string? | URL logo di Firebase Storage |
| `bankAccountInfo` | map | `{bankName, accountNumber, accountHolder}` |
| `qrisImageUrl` | string? | URL gambar QRIS jika ada |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |
| `isSetupComplete` | boolean | Menentukan apakah user diarahkan ke onboarding atau dashboard |

### 5.3 `businesses/{uid}/services/{serviceId}`

| Field | Tipe | Keterangan |
|---|---|---|
| `serviceId` | string | Auto ID Firestore |
| `serviceName` | string | Contoh: "Servis AC 1 PK" |
| `category` | string | Contoh: "Perbaikan" |
| `price` | number | Harga standar (Rupiah, integer) |
| `estimatedDuration` | string | Contoh: "1-2 jam" |
| `description` | string? | Catatan tambahan |
| `isActive` | boolean | Untuk soft-hide layanan tanpa menghapus histori |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |

### 5.4 `businesses/{uid}/customers/{customerId}`

| Field | Tipe | Keterangan |
|---|---|---|
| `customerId` | string | Auto ID Firestore |
| `name` | string | Nama pelanggan |
| `phoneNumber` | string | Wajib, digunakan untuk kirim invoice via WA |
| `email` | string? | Opsional |
| `address` | string? | Opsional |
| `notes` | string? | Catatan khusus pelanggan |
| `totalTransactions` | number | Counter, di-update tiap transaksi baru (denormalized untuk performa) |
| `totalSpent` | number | Akumulasi nominal transaksi (denormalized) |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |

### 5.5 `businesses/{uid}/transactions/{transactionId}`

| Field | Tipe | Keterangan |
|---|---|---|
| `transactionId` | string | Auto ID Firestore |
| `invoiceNumber` | string | Format: `INV/{businessInitial}/{YYYYMM}/{sequence}` — lihat Bagian 8 |
| `transactionDate` | timestamp | Tanggal transaksi dibuat |
| `customerId` | string | Referensi ke `customers/{customerId}` |
| `customerSnapshot` | map | `{name, phoneNumber, address}` — disalin saat transaksi dibuat agar invoice tetap valid meski data pelanggan diubah di kemudian hari |
| `items` | array\<map\> | Daftar jasa yang dibeli — lihat struktur `TransactionItem` di 5.6 |
| `subtotal` | number | Jumlah sebelum diskon/biaya tambahan |
| `discountAmount` | number | Nominal diskon (default 0) |
| `discountNote` | string? | Alasan diskon (opsional) |
| `additionalFee` | number | Biaya tambahan (misal ongkos kirim) |
| `additionalFeeNote` | string? | |
| `totalAmount` | number | `subtotal - discountAmount + additionalFee` |
| `paymentMethod` | string | Enum: `cash`, `transfer`, `qris` |
| `paymentStatus` | string | Enum: `paid`, `unpaid`, `partial` |
| `amountPaid` | number | Untuk kasus `partial` |
| `jobStatus` | string | Enum: `waiting`, `in_progress`, `done`, `delivered` |
| `notes` | string? | Catatan transaksi |
| `createdAt` | timestamp | |
| `updatedAt` | timestamp | |

### 5.6 Struktur `TransactionItem` (embedded array, bukan subkoleksi)

Karena jumlah item per transaksi kecil (umumnya 1–10 item) dan selalu diakses bersamaan dengan dokumen transaksi induknya, item disimpan sebagai **array of map** di dalam dokumen transaksi — bukan subkoleksi terpisah. Ini mengurangi jumlah read Firestore dan mempermudah pembuatan PDF invoice dalam satu kali fetch.

```json
{
  "serviceId": "abc123",
  "serviceName": "Servis AC 1 PK",
  "price": 150000,
  "quantity": 1,
  "lineTotal": 150000
}
```

### 5.7 `businesses/{uid}/settings/general`

| Field | Tipe | Keterangan |
|---|---|---|
| `invoicePrefix` | string | Default "INV", bisa dikustomisasi pengguna |
| `invoiceSequenceCounter` | number | Counter berjalan untuk generate nomor invoice |
| `invoiceFooterNote` | string | Contoh: "Terima kasih telah menggunakan jasa kami" |
| `defaultPaymentMethod` | string | |
| `currencyFormat` | string | Default "IDR" |

---

## 6. Firebase Authentication Flow

1. **Splash Screen** → cek status `FirebaseAuth.instance.authStateChanges()`.
2. Jika belum login → arahkan ke `LoginScreen`.
3. Login tersedia via:
   - Email + Password (`signInWithEmailAndPassword`)
   - Google Sign-In (`GoogleAuthProvider`)
4. Jika register baru → `createUserWithEmailAndPassword`, lalu otomatis buat dokumen `businesses/{uid}` dengan `isSetupComplete: false`.
5. Setelah login berhasil:
   - Cek dokumen `businesses/{uid}`.
   - Jika `isSetupComplete == false` → arahkan ke `BusinessSetupScreen` (onboarding).
   - Jika `isSetupComplete == true` → arahkan ke `DashboardScreen`.
6. Lupa password → `sendPasswordResetEmail`.
7. Logout → `FirebaseAuth.instance.signOut()` + clear seluruh provider state (invalidate Riverpod providers agar tidak ada data bocor ke sesi berikutnya jika device dipakai bergantian).

---

## 7. Firebase Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isOwner(businessId) {
      return request.auth != null && request.auth.uid == businessId;
    }

    match /businesses/{businessId} {
      allow read, update: if isOwner(businessId);
      allow create: if request.auth != null && request.auth.uid == businessId;
      allow delete: if false; // Tidak boleh hapus akun usaha via client

      match /services/{serviceId} {
        allow read, write: if isOwner(businessId);
      }

      match /customers/{customerId} {
        allow read, write: if isOwner(businessId);
      }

      match /transactions/{transactionId} {
        allow read, write: if isOwner(businessId);
      }

      match /settings/{settingId} {
        allow read, write: if isOwner(businessId);
      }
    }
  }
}
```

**Firebase Storage Rules:**

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /businesses/{businessId}/logo/{fileName} {
      allow read: if true; // Logo perlu diakses saat generate PDF
      allow write: if request.auth != null && request.auth.uid == businessId;
    }
  }
}
```

---

## 8. Penomoran Invoice Otomatis

Format: `INV/{3 huruf inisial usaha}/{YYYYMM}/{sequence 4 digit}`

Contoh: `INV/BRZ/202607/0001`

**Alur generate:**
1. Ambil `invoiceSequenceCounter` dari `businesses/{uid}/settings/general`.
2. Increment counter menggunakan **Firestore Transaction** (`runTransaction`) agar tidak terjadi race condition/duplikasi nomor jika ada dua transaksi dibuat hampir bersamaan.
3. Reset counter setiap awal bulan (opsional, dapat dikonfigurasi) atau counter berjalan terus — ini adalah keputusan yang dituliskan di `settings.general` melalui field tambahan `resetCounterMonthly: boolean`.
4. Nomor invoice final disimpan permanen di field `invoiceNumber` pada dokumen transaksi — tidak pernah digenerate ulang meski data lain diubah.

---

## 9. Alur Pembuatan Invoice PDF

1. User membuka `TransactionDetailScreen`, menekan tombol "Buat Invoice".
2. `InvoiceService` mengambil data transaksi lengkap (sudah termasuk `customerSnapshot` dan `items`, tanpa perlu query tambahan).
3. `PdfGeneratorService` menyusun dokumen PDF menggunakan package `pdf`:
   - Header: logo usaha (dari `logoUrl`, di-cache lokal), nama usaha, alamat, WA.
   - Info invoice: nomor invoice, tanggal, status pembayaran.
   - Data pelanggan.
   - Tabel rincian jasa (nama, qty, harga satuan, subtotal per baris).
   - Ringkasan: subtotal, diskon, biaya tambahan, total akhir dalam format Rupiah.
   - Footer: catatan terima kasih dan info rekening/QRIS jika `paymentStatus != paid`.
4. Dokumen dirender ke `Uint8List` lalu:
   - **Preview** menggunakan `Printing.layoutPdf()`.
   - **Simpan lokal** ke direktori sementara via `path_provider`.
   - **Bagikan** via `share_plus` ke WhatsApp/email/aplikasi lain.
5. Field `invoiceGeneratedAt` di-update pada dokumen transaksi sebagai jejak bahwa invoice pernah dibuat (tidak menyimpan file PDF di Storage secara default agar hemat kuota — hanya digenerate ulang on-demand dari data Firestore; opsi arsip PDF ke Storage dijadikan pengaturan opsional di `settings`).

---

## 10. Status Pekerjaan (Job Tracking)

Field `jobStatus` pada dokumen transaksi memiliki 4 tahap linear:

```
waiting → in_progress → done → delivered
```

- Ditampilkan sebagai stepper/badge berwarna di `TransactionDetailScreen` dan `TransactionListScreen`.
- Perubahan status memicu `updatedAt` ter-update dan dapat memicu notifikasi lokal (opsional) untuk mengingatkan pemilik usaha soal pekerjaan yang lama tidak berpindah status.
- Status ini independen dari `paymentStatus` — sebuah transaksi bisa saja `paid` tapi `jobStatus: in_progress` (dibayar di muka), atau `delivered` tapi `paymentStatus: unpaid` (bayar belakangan/termin).

---

## 11. Laporan Pendapatan

`ReportService` melakukan agregasi dari koleksi `transactions` dengan filter `paymentStatus == paid` (atau opsi menghitung `amountPaid` untuk status `partial`), dikelompokkan berdasarkan:

- **Harian** — query dengan range `transactionDate` hari berjalan.
- **Mingguan** — 7 hari terakhir.
- **Bulanan** — awal s/d akhir bulan berjalan.
- **Tahunan** — agregasi per bulan dalam satu tahun untuk grafik tren (`fl_chart` line/bar chart).

**Pertimbangan performa:** untuk MVP, agregasi dilakukan di sisi client (Flutter) dari hasil query Firestore dengan range tanggal + index composite pada `transactionDate` dan `paymentStatus`. Jika volume transaksi per UMKM sudah sangat besar (>10.000 dokumen/tahun), pertimbangkan migrasi agregasi ke **Cloud Functions terjadwal** yang menulis dokumen ringkasan (`businesses/{uid}/reportSummaries/{yyyymm}`) — dicatat sebagai item roadmap, bukan kebutuhan MVP.

---

## 12. State Management — Struktur Riverpod

Pola: `StateNotifierProvider` atau `AsyncNotifierProvider` per domain, dikombinasikan dengan `StreamProvider` untuk data real-time dari Firestore.

Contoh struktur (skema, bukan kode final):

```dart
// providers/customer_provider.dart

final customerServiceProvider = Provider((ref) => CustomerService());

final customerListProvider = StreamProvider.autoDispose<List<CustomerModel>>((ref) {
  final service = ref.watch(customerServiceProvider);
  final uid = ref.watch(currentUserIdProvider);
  return service.watchCustomers(uid);
});

final customerFormProvider = StateNotifierProvider.autoDispose<
    CustomerFormNotifier, CustomerFormState>((ref) {
  return CustomerFormNotifier(ref.watch(customerServiceProvider));
});
```

**Konvensi:**
- Semua `StreamProvider` yang bergantung pada data real-time (daftar transaksi, dashboard) menggunakan `.autoDispose` agar listener dibersihkan saat halaman ditutup.
- Provider yang butuh survive antar halaman (misal `currentUserIdProvider`, `businessProfileProvider`) tidak menggunakan `autoDispose`.
- Form state menggunakan `StateNotifier` dengan state class yang eksplisit (`CustomerFormState { data, isSubmitting, errorMessage }`), bukan `ChangeNotifier` biasa.

---

## 13. Routing — go_router

| Path | Screen | Guard |
|---|---|---|
| `/splash` | SplashScreen | - |
| `/login` | LoginScreen | Redirect ke `/dashboard` jika sudah login |
| `/register` | RegisterScreen | idem |
| `/onboarding` | BusinessSetupScreen | Hanya bisa diakses jika `isSetupComplete == false` |
| `/dashboard` | DashboardScreen | Wajib login & setup selesai |
| `/services` | ServiceListScreen | idem |
| `/services/form` | ServiceFormScreen | idem (query param `serviceId` untuk edit) |
| `/customers` | CustomerListScreen | idem |
| `/customers/:id` | CustomerDetailScreen | idem |
| `/customers/form` | CustomerFormScreen | idem |
| `/transactions` | TransactionListScreen | idem |
| `/transactions/form` | TransactionFormScreen | idem |
| `/transactions/:id` | TransactionDetailScreen | idem |
| `/reports` | ReportScreen | idem |
| `/settings` | SettingsScreen | idem |
| `/settings/business-profile` | BusinessProfileScreen | idem |

Redirect logic terpusat di satu `redirect` callback pada `GoRouter`, membaca `authStateProvider` dan `businessSetupStatusProvider` sekaligus agar tidak ada logic auth tercecer di banyak screen.

---

## 14. Model Data (Ringkasan Struktur Dart)

Semua model bersifat **immutable**, memiliki `fromFirestore(DocumentSnapshot)`, `toMap()`, dan `copyWith()`.

```dart
class TransactionModel {
  final String transactionId;
  final String invoiceNumber;
  final DateTime transactionDate;
  final String customerId;
  final CustomerSnapshot customerSnapshot;
  final List<TransactionItemModel> items;
  final int subtotal;
  final int discountAmount;
  final int additionalFee;
  final int totalAmount;
  final String paymentMethod; // cash | transfer | qris
  final String paymentStatus; // paid | unpaid | partial
  final int amountPaid;
  final String jobStatus; // waiting | in_progress | done | delivered
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({ ... });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toMap() { ... }
  TransactionModel copyWith({ ... }) { ... }
}
```

Model lain (`BusinessModel`, `ServiceModel`, `CustomerModel`, `TransactionItemModel`) mengikuti pola yang sama. Seluruh enum (`paymentStatus`, `jobStatus`, `paymentMethod`) disimpan sebagai `String` di Firestore (bukan tipe custom) agar query `whereIn`/`where` tetap sederhana, namun di-mapping ke Dart `enum` pada layer model untuk type-safety di UI.

---

## 15. Validasi & Aturan Bisnis

- Nomor telepon pelanggan wajib diisi (validasi format Indonesia: awalan `08` atau `+62`).
- Transaksi harus memiliki minimal 1 item jasa.
- `totalAmount` selalu dihitung ulang di sisi client sebelum disimpan (`subtotal - discountAmount + additionalFee`), tidak pernah diinput manual, untuk mencegah inkonsistensi data.
- `discountAmount` tidak boleh melebihi `subtotal`.
- Perubahan `paymentStatus` ke `paid` otomatis mengisi `amountPaid = totalAmount` jika sebelumnya kosong.
- Penghapusan layanan jasa (`services`) menggunakan **soft delete** (`isActive: false`), bukan hard delete — karena riwayat transaksi lama masih mereferensikan `serviceId` tersebut (walau data harga sudah di-snapshot di `items`, nama layanan tetap perlu tersedia untuk keperluan filter/laporan).
- Semua pesan error dan label form menggunakan Bahasa Indonesia yang jelas, contoh: `"Nomor WhatsApp tidak valid"`, `"Pilih minimal satu layanan"`.

---

## 16. Non-Functional Requirements

| Aspek | Kebutuhan |
|---|---|
| Bahasa UI | 100% Bahasa Indonesia |
| Offline support | Firestore offline persistence diaktifkan (`Firestore.setPersistenceEnabled`) agar transaksi tetap bisa dicatat tanpa koneksi lalu tersinkron otomatis |
| Keamanan | Security Rules ketat per `uid`; tidak ada endpoint publik yang membocorkan data usaha lain |
| Performa | Query selalu di-scope ke subkoleksi milik `uid` sendiri; gunakan index composite untuk kombinasi filter (`paymentStatus` + `transactionDate`) |
| Skalabilitas | Struktur single-tenant memungkinkan sharding alami — tidak ada dokumen bersama antar UMKM yang berisiko menjadi hotspot |
| Konsistensi angka | Semua nominal disimpan sebagai `int` (satuan Rupiah, bukan desimal) untuk menghindari floating point error |
| Aksesibilitas device rendah | UI ringan, hindari widget berat/animasi berlebihan mengingat target pengguna UMKM sering memakai HP entry-level |
