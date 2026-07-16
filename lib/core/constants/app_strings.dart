class AppStrings {
  AppStrings._();

  static const String appName = 'MISA';
  static const String appFullName = 'Mobile Invoice & Service Application';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Konfirmasi Password';
  static const String forgotPassword = 'Lupa Password?';
  static const String resetPassword = 'Atur Ulang Password';
  static const String resetPasswordSent = 'Email reset password telah dikirim';
  static const String loginWithGoogle = 'Masuk dengan Google';
  static const String noAccount = 'Belum punya akun?';
  static const String hasAccount = 'Sudah punya akun?';
  static const String registerSuccess = 'Pendaftaran berhasil!';
  static const String loginSuccess = 'Masuk berhasil!';

  // Onboarding
  static const String setupBusiness = 'Siapkan Usaha Anda';
  static const String ownerName = 'Nama Pemilik';
  static const String businessName = 'Nama Usaha';
  static const String businessCategory = 'Kategori Usaha';
  static const String address = 'Alamat';
  static const String whatsappNumber = 'Nomor WhatsApp';
  static const String finishSetup = 'Selesai';

  // Dashboard
  static const String dashboard = 'Beranda';
  static const String todayIncome = 'Pendapatan Hari Ini';
  static const String monthlyIncome = 'Pendapatan Bulan Ini';
  static const String totalCustomers = 'Total Pelanggan';
  static const String pendingJobs = 'Pekerjaan Pending';
  static const String recentTransactions = 'Transaksi Terbaru';
  static const String viewAll = 'Lihat Semua';

  // Services
  static const String services = 'Layanan';
  static const String addService = 'Tambah Layanan';
  static const String editService = 'Edit Layanan';
  static const String serviceName = 'Nama Layanan';
  static const String category = 'Kategori';
  static const String price = 'Harga';
  static const String estimatedDuration = 'Estimasi Durasi';
  static const String description = 'Deskripsi';
  static const String isActive = 'Aktif';
  static const String deactivateService = 'Nonaktifkan Layanan';
  static const String deleteService = 'Hapus Layanan';

  // Customers
  static const String customers = 'Pelanggan';
  static const String addCustomer = 'Tambah Pelanggan';
  static const String editCustomer = 'Edit Pelanggan';
  static const String customerName = 'Nama Pelanggan';
  static const String phoneNumber = 'Nomor Telepon';
  static const String customerEmail = 'Email (Opsional)';
  static const String customerAddress = 'Alamat (Opsional)';
  static const String customerNotes = 'Catatan (Opsional)';
  static const String totalTransactions = 'Total Transaksi';
  static const String totalSpent = 'Total Belanja';

  // Transactions
  static const String transactions = 'Transaksi';
  static const String addTransaction = 'Tambah Transaksi';
  static const String editTransaction = 'Edit Transaksi';
  static const String transactionDetail = 'Detail Transaksi';
  static const String selectCustomer = 'Pilih Pelanggan';
  static const String addItem = 'Tambah Item';
  static const String selectService = 'Pilih Layanan';
  static const String quantity = 'Jumlah';
  static const String subtotal = 'Subtotal';
  static const String discount = 'Diskon';
  static const String discountNote = 'Catatan Diskon';
  static const String additionalFee = 'Biaya Tambahan';
  static const String additionalFeeNote = 'Catatan Biaya Tambahan';
  static const String totalAmount = 'Total';
  static const String paymentMethod = 'Metode Pembayaran';
  static const String paymentStatus = 'Status Pembayaran';
  static const String jobStatus = 'Status Pekerjaan';
  static const String notes = 'Catatan';

  // Payment
  static const String cash = 'Tunai';
  static const String transfer = 'Transfer';
  static const String qris = 'QRIS';
  static const String paid = 'Lunas';
  static const String unpaid = 'Belum Dibayar';
  static const String partial = 'Bayar Sebagian';
  static const String amountPaid = 'Jumlah Dibayar';

  // Job Status
  static const String waiting = 'Menunggu';
  static const String inProgress = 'Dikerjakan';
  static const String done = 'Selesai';
  static const String delivered = 'Terkirim';

  // Invoice
  static const String invoice = 'Invoice';
  static const String createInvoice = 'Buat Invoice';
  static const String previewInvoice = 'Preview Invoice';
  static const String shareInvoice = 'Bagikan Invoice';
  static const String downloadInvoice = 'Unduh Invoice';
  static const String printInvoice = 'Cetak Invoice';
  static const String invoiceGenerated = 'Invoice berhasil dibuat';

  // Reports
  static const String reports = 'Laporan';
  static const String dailyReport = 'Harian';
  static const String weeklyReport = 'Mingguan';
  static const String monthlyReport = 'Bulanan';
  static const String yearlyReport = 'Tahunan';
  static const String totalRevenue = 'Total Pendapatan';
  static const String totalTransactionsReport = 'Total Transaksi';
  static const String averageTransaction = 'Rata-rata Transaksi';

  // Settings
  static const String settings = 'Pengaturan';
  static const String businessProfile = 'Profil Usaha';
  static const String invoiceSettings = 'Pengaturan Invoice';
  static const String invoicePrefix = 'Prefix Invoice';
  static const String invoiceFooterNote = 'Catatan Footer Invoice';
  static const String bankAccountInfo = 'Informasi Rekening Bank';
  static const String bankName = 'Nama Bank';
  static const String accountNumber = 'Nomor Rekening';
  static const String accountHolder = 'Nama Pemilik Rekening';
  static const String logo = 'Logo Usaha';
  static const String qrisImage = 'Gambar QRIS';

  // Validation
  static const String fieldRequired = 'Field ini wajib diisi';
  static const String invalidEmail = 'Format email tidak valid';
  static const String invalidPhone = 'Nomor telepon tidak valid';
  static const String passwordTooShort = 'Password minimal 6 karakter';
  static const String passwordNotMatch = 'Password tidak cocok';
  static const String selectAtLeastOneService = 'Pilih minimal satu layanan';
  static const String discountExceedsSubtotal = 'Diskon tidak boleh melebihi subtotal';
  static const String noCustomerSelected = 'Pilih pelanggan terlebih dahulu';

  // General
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Edit';
  static const String add = 'Tambah';
  static const String confirm = 'Konfirmasi';
  static const String loading = 'Memuat...';
  static const String noData = 'Tidak ada data';
  static const String error = 'Terjadi kesalahan';
  static const String retry = 'Coba Lagi';
  static const String search = 'Cari...';
  static const String filter = 'Filter';
  static const String all = 'Semua';
  static const String today = 'Hari Ini';
  static const String thisWeek = 'Minggu Ini';
  static const String thisMonth = 'Bulan Ini';
  static const String thisYear = 'Tahun Ini';
  static const String thankYou = 'Terima kasih telah menggunakan jasa kami';
  static const String idr = 'Rp';
}
