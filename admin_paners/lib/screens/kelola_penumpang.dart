import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'detail_penumpang.dart';
import 'admin_home_screen.dart';
import 'kelola_bus.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

// Import untuk fitur unduh CSV
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'pemesanan_manual_screen.dart';


class KelolaPenumpangScreen extends StatefulWidget {
  const KelolaPenumpangScreen({super.key});

  @override
  State<KelolaPenumpangScreen> createState() => _KelolaPenumpangScreenState();
}

class _KelolaPenumpangScreenState extends State<KelolaPenumpangScreen> {
  DateTime? selectedDate;
  String? formattedDate;
  String? selectedStatusFilter; // State untuk filter status

  int terverifikasiCount = 0;
  int menungguKonfirmasiCount = 0;
  int gagalCount = 0;

  // GlobalKey untuk StreamBuilder agar bisa memicu refresh
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle removed from here as it's set globally in main.dart
    // Atau diatur di awal build method jika halaman ini punya warna background yang unik.
    // Jika Anda ingin status bar putih di layar ini (karena background biru), Anda bisa mengatur di sini:
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0xFF0D4695), // Background status bar biru
        statusBarIconBrightness: Brightness.light, // Ikon status bar putih
        statusBarBrightness: Brightness.dark, // Untuk iOS
        systemNavigationBarColor: Colors.white, // Navigation bar putih
        systemNavigationBarIconBrightness: Brightness.dark, // Ikon navigation bar hitam
      ),
    );

    selectedDate = DateTime.now();
    formattedDate = DateFormat('dd MMM yyyy').format(selectedDate!); // Pastikan format ini cocok dengan Firebase
    selectedStatusFilter = null; // Default: Semua Status
    _updateStatusCounts();
    print('Initial formattedDate: $formattedDate');
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(2100),
      builder: (context, child) {
        // Theme DatePicker agar konsisten dengan desain aplikasi
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D4695), // Warna header date picker
              onPrimary: Colors.white,   // Warna teks pada tanggal yang dipilih
              surface: Colors.white,     // Background kalender
              onSurface: Colors.black,   // Warna teks kalender
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D4695), // OK/Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('dd MMM yyyy').format(picked); // Pastikan format ini cocok
        selectedStatusFilter = null; // Reset filter status saat tanggal berubah
        _updateStatusCounts(); // Panggil fungsi untuk memperbarui jumlah status
        print('Picked formattedDate: $formattedDate');
      });
    }
  }

  Future<void> _updateStatusCounts() async {
    if (formattedDate == null) {
      setState(() {
        terverifikasiCount = 0;
        menungguKonfirmasiCount = 0;
        gagalCount = 0;
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('pemesanan')
          .where('tanggal', isEqualTo: formattedDate!)
          .get();

      int tempTerverifikasi = 0;
      int tempMenungguKonfirmasi = 0;
      int tempGagal = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';

        if (status == 'Terverifikasi') {
          tempTerverifikasi++;
        } else if (status == 'Menunggu Konfirmasi') {
          tempMenungguKonfirmasi++;
        } else if (status == 'Gagal') {
          tempGagal++;
        }
      }

      setState(() {
        terverifikasiCount = tempTerverifikasi;
        menungguKonfirmasiCount = tempMenungguKonfirmasi;
        gagalCount = tempGagal;
      });
    } catch (e) {
      print("Error fetching status counts: $e");
      setState(() {
        terverifikasiCount = 0;
        menungguKonfirmasiCount = 0;
        gagalCount = 0;
      });
    }
  }

  // Start of new code for Sign Out confirmation
  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin keluar dari akun ini?', style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak', style: GoogleFonts.poppins(color: Colors.red)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Ya', style: GoogleFonts.poppins(color: Colors.green)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
  // End of new code for Sign Out confirmation

  // Start of new code for Download CSV
 Future<void> _downloadReport() async {
  if (formattedDate == null || formattedDate!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pilih tanggal terlebih dahulu untuk mengunduh laporan.')),
    );
    return;
  }

  // Meminta izin penyimpanan
  // permission_handler sudah cukup baik di sini, pastikan AndroidManifest.xml sudah benar
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      // Jika izin ditolak, beritahu pengguna dan tawarkan untuk membuka pengaturan
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Izin penyimpanan ditolak. Mohon berikan izin di pengaturan aplikasi.'),
            action: SnackBarAction(
              label: 'Pengaturan',
              onPressed: () {
                openAppSettings(); // Buka pengaturan aplikasi agar pengguna bisa memberikan izin
              },
            ),
          ),
        );
      }
      return;
    }
  }

  try {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengunduh laporan...')),
      );
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('pemesanan')
        .where('tanggal', isEqualTo: formattedDate!)
        .get();

    List<List<dynamic>> csvData = [
      // Header CSV
      ['Kode Pemesanan', 'Asal', 'Tujuan', 'Tanggal', 'Jam', 'Kelas', 'Nama', 'Telepon', 'Jumlah Kursi', 'Kursi Dipilih', 'Metode Pembayaran', 'Status', 'Dipesan Pada', 'Total Pembayaran']
    ];

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      csvData.add([
        data['kode_pemesanan'] ?? '',
        data['asal'] ?? '',
        data['tujuan'] ?? '',
        data['tanggal'] ?? '',
        data['jam'] ?? '',
        data['kelas'] ?? '',
        data['nama'] ?? '',
        data['telepon'] ?? '',
        data['jumlah_kursi'] ?? 0,
        (data['kursi'] as List<dynamic>?)?.join(', ') ?? '', // Join list of seats
        data['metode_pembayaran'] ?? '',
        data['status'] ?? '',
        (data['dipesan_pada'] as Timestamp?)?.toDate().toLocal().toString() ?? '', // Format Timestamp
        data['total_pembayaran'] ?? 0,
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);

    // --- PENTING: Perubahan di sini untuk direktori penyimpanan ---
    // Menggunakan getApplicationDocumentsDirectory() sebagai opsi yang lebih aman dan umum
    // File ini biasanya hanya dapat diakses oleh aplikasi Anda sendiri.
    // Jika Anda benar-benar perlu menyimpan ke direktori yang bisa diakses user umum (seperti Downloads),
    // maka Anda harus menggunakan plugin yang lebih canggih atau API Android yang lebih spesifik.
    final directory = await getApplicationDocumentsDirectory(); 

    if (directory == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat menemukan direktori penyimpanan.')),
        );
      }
      return;
    }

    // Buat folder 'BusBookings' di dalam direktori aplikasi
    final appSpecificDir = Directory('${directory.path}/BusBookings');
    if (!await appSpecificDir.exists()) {
      await appSpecificDir.create(recursive: true);
    }

    final fileName = 'Pemesanan_${formattedDate!.replaceAll('/', '-')}.csv';
    final file = File('${appSpecificDir.path}/$fileName');
    await file.writeAsString(csv);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Laporan berhasil diunduh ke: ${file.path}'),
          action: SnackBarAction(
            label: 'Buka',
            onPressed: () {
              OpenFilex.open(file.path);
            },
          ),
        ),
      );
    }
  } catch (e) {
    print("Error downloading report: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh laporan: ${e.toString()}')),
      );
    }
  }
}
  // End of new code for Download CSV

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4695),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D4695)),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20.sp),
                ),
              ),
            ),
            _drawerItem(context, Icons.home, 'Beranda', () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
            }),
            _drawerItem(context, Icons.directions_bus, 'Kelola Bus', () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => KelolaBusScreen()));
            }),
            _drawerItem(context, Icons.people, 'Penumpang', () {
              Navigator.pop(context);
            }, active: true),
            _drawerItem(context, Icons.receipt, 'Pemesanan Manual', () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PemesananManualScreen()),
              );
            }),
            Divider(
              thickness: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Colors.grey[300],
            ),
            _drawerItem(context, Icons.logout, 'Sign Out', () {
              Navigator.pop(context); // Close the drawer first
              _confirmSignOut(context); // Then show the confirmation dialog
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "List Pemesanan Bus",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Start of new code: Refresh button in AppBar
                    const Spacer(), // Dorong tombol refresh ke kanan
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        // Memicu refresh StreamBuilder
                        setState(() {
                          // Memuat ulang data dengan memicu update state atau memanggil _updateStatusCounts
                          // Untuk StreamBuilder, cukup memicu setState yang memuat ulang Stream
                          // agar lebih eksplisit, kita bisa memanggil _updateStatusCounts()
                          _updateStatusCounts();
                        });
                        // Opsional: tampilkan snackbar "Data diperbarui"
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Data diperbarui.')),
                        );
                      },
                    ),
                    // End of new code: Refresh button in AppBar
                  ],
                ),
              ),
              Image.asset('assets/images/identitas_logo.png', height: 100.h),
              TextButton(
                onPressed: _pickDate,
                child: Text(
                  formattedDate ?? 'Pilih Tanggal',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
                ),
              ),
              Divider(
                thickness: 1,
                indent: 60.w,
                endIndent: 60.w,
                color: Colors.white70,
              ),
              SizedBox(height: 8.h),

              Row( // Menggunakan Row untuk menempatkan tombol Cari dan Unduh berdampingan
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD100),
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h), // Padding disesuaikan
                    ),
                    child: Text("Cari", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(width: 12.w), // Spasi antara tombol Cari dan Unduh
                  // Start of new code: Download Button
                  if (formattedDate != null && (terverifikasiCount + menungguKonfirmasiCount + gagalCount > 0)) // Tampilkan tombol jika tanggal dipilih dan ada data
                    ElevatedButton.icon(
                      onPressed: _downloadReport,
                      icon: Icon(Icons.download, size: 20.sp, color: Colors.white),
                      label: Text("Unduh CSV", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Warna hijau untuk unduh
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      ),
                    ),
                  // End of new code: Download Button
                ],
              ),
              SizedBox(height: 16.h),
              // Menampilkan jumlah status pemesanan
              if (formattedDate != null) ...[
                Text(
                  'Total Pemesanan (${formattedDate!})',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusCountCard('Terverifikasi', terverifikasiCount, Colors.green),
                    _buildStatusCountCard('Menunggu Konfirmasi', menungguKonfirmasiCount, const Color(0xFFFFD100)),
                    _buildStatusCountCard('Gagal', gagalCount, Colors.red),
                  ],
                ),
              ],

              SizedBox(height: 16.h),
              // Dropdown Filter Status
              _buildStatusDropdownFilter(),
              SizedBox(height: 8.h),

              Expanded(
                child: RefreshIndicator( // Bungkus StreamBuilder dengan RefreshIndicator
                  key: _refreshIndicatorKey, // Assign key
                  onRefresh: () async {
                    // Logika refresh: memuat ulang data atau memanggil _updateStatusCounts()
                    await _updateStatusCounts();
                    setState(() {
                      // Ini akan memicu StreamBuilder untuk memuat ulang data
                    });
                  },
                  child: StreamBuilder<QuerySnapshot>(
                    stream: (formattedDate == null || formattedDate!.isEmpty)
                        ? FirebaseFirestore.instance.collection('pemesanan').snapshots()
                        : (selectedStatusFilter == null)
                            ? FirebaseFirestore.instance
                                .collection('pemesanan')
                                .where('tanggal', isEqualTo: formattedDate!)
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('pemesanan')
                                .where('tanggal', isEqualTo: formattedDate!)
                                .where('status', isEqualTo: selectedStatusFilter!)
                                .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "Tidak ada pemesanan",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
                          ),
                        );
                      }
                      return ListView(
                        padding: EdgeInsets.all(16.w),
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon
                                SizedBox(
                                  width: 40.w,
                                  height: 40.h,
                                  child: Image.asset('assets/icons/ticket.png'),
                                ),
                                SizedBox(width: 12.w),

                                // Kolom teks, Flexible agar tidak mengambil semua ruang
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(data['nama'] ?? '-', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                      Text('${data['asal']} - ${data['tujuan']}', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                      Text(data['tanggal'] ?? '', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                      Text('Dipesan : ${data['jumlah_kursi'] ?? '..'}', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                      Row(
                                        children: [
                                          Text('Status: ', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500)),
                                          Text(
                                            data['status'] ?? '',
                                            style: GoogleFonts.poppins(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              color: data['status'] == 'Terverifikasi'
                                                  ? Colors.green
                                                  : data['status'] == 'Menunggu Konfirmasi'
                                                      ? const Color(0xFFFFD100)
                                                      : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Tombol Detail diatur agar fleksibel
                                Flexible(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailPenumpangScreen(pemesanan: doc),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Detail',
                                        style: GoogleFonts.poppins(
                                          color: Colors.black87,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: active ? Colors.blue : Colors.black),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: active ? Colors.blue : Colors.black,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatusCountCard(String status, int count, Color color) {
    return Column(
      children: [
        Text(
          status,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14.sp),
        ),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(color: color, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusDropdownFilter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedStatusFilter,
          icon: Icon(Icons.arrow_drop_down, color: Colors.black, size: 24.sp),
          elevation: 16,
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 14.sp),
          onChanged: (String? newValue) {
            setState(() {
              selectedStatusFilter = newValue;
            });
          },
          items: <Map<String, String?>>[
            {'label': 'Semua Status', 'value': null},
            {'label': 'Menunggu Konfirmasi', 'value': 'Menunggu Konfirmasi'},
            {'label': 'Terverifikasi', 'value': 'Terverifikasi'},
            {'label': 'Gagal', 'value': 'Gagal'},
          ].map<DropdownMenuItem<String?>>((Map<String, String?> item) {
            return DropdownMenuItem<String?>(
              value: item['value'],
              child: Text(item['label']!),
            );
          }).toList(),
        ),
      ),
    );
  }
}