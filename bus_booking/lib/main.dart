import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman PENGGUNA
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pesan_tiket_screen.dart';
import 'screens/info_keberangkatan_screen.dart';
import 'screens/informasi_penumpang.dart'; // Halaman informasi penumpang
import 'screens/pembayaran.dart'; // Halaman pembayaran

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Atur style sistem UI global:
  // Status bar dan Navigation Bar background putih.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Background Status Bar PUTIH
      statusBarIconBrightness: Brightness.dark, // Default: ikon Status Bar hitam (cocok untuk latar putih)
      statusBarBrightness: Brightness.light,    // Untuk iOS: teks gelap (kontras dengan background putih)

      systemNavigationBarColor: Colors.white, // Background Navigation Bar PUTIH
      systemNavigationBarIconBrightness: Brightness.dark, // Default: ikon Navigation Bar hitam (cocok untuk latar putih)
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Daftar route aplikasi PENGGUNA
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String pesanTiketRoute = '/pesan_tiket';
  static const String infoKeberangkatanRoute = '/info_keberangkatan';
  static const String informasiPenumpangRoute = '/informasi_penumpang'; // Route untuk informasi penumpang
  static const String pembayaranRoute = '/pembayaran'; // Route untuk pembayaran

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit di sini akan membuat seluruh aplikasi responsif
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Desain referensi (lebar 375pt, tinggi 812pt)
      minTextAdapt: true, // Ukuran teks akan menyesuaikan diri
      splitScreenMode: true, // Mendukung mode split screen
      builder: (context, child) {
        return MaterialApp(
          title: 'Bus Ticket Booking', // Ubah judul aplikasi jika perlu
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            primaryColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              systemOverlayStyle: SystemUiOverlayStyle.dark, // Ikon status bar hitam untuk AppBar yang cerah
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ).apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
          ),
          initialRoute: splashRoute,
          routes: {
            splashRoute: (context) => SplashScreen(),
            loginRoute: (context) => LoginScreen(),
            homeRoute: (context) => HomeScreen(),
            pesanTiketRoute: (context) => PesanTiketScreen(),
            infoKeberangkatanRoute: (context) => InfoKeberangkatanScreen(),
            informasiPenumpangRoute: (context) => InformasiPenumpangScreen(
              dari: ModalRoute.of(context)?.settings.arguments as String? ?? '', // Contoh pengambilan argumen
              tujuan: '', // Sesuaikan pengambilan argumen
              waktu: '',
              selectedSeats: {},
              hargaTiketPerKursi: 0,
              kelas: '',
            ),
            pembayaranRoute: (context) => PembayaranScreen(
              asal: '', // Sesuaikan pengambilan argumen
              tujuan: '',
              tanggal: '',
              jam: '',
              nama: '',
              telepon: '',
              jumlahKursi: 0,
              kursiDipilih: [],
              totalPembayaran: 0,
              kelas: '',
            ),
            // Hapus semua route yang berhubungan dengan admin dari sini
            // Misalnya:
            // adminHomeRoute: (context) => AdminHomeScreen(),
            // kelolaBusRoute: (context) => KelolaBusScreen(),
            // kelolaPenumpangRoute: (context) => KelolaPenumpangScreen(),
            // detailPenumpangRoute: (context) => DetailPenumpangScreen(pemesanan: ModalRoute.of(context)!.settings.arguments as dynamic),
          },
        );
      },
    );
  }
}