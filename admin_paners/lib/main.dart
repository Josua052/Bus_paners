import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

// Import halaman
import 'screens/splash_screen.dart';
import 'screens/admin_isi_penumpang_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/kelola_bus.dart';
import 'screens/kelola_penumpang.dart';
import 'screens/detail_penumpang.dart'; // Jika DetailPenumpangScreen digunakan di aplikasi admin
import 'screens/pemesanan_manual_screen.dart'; // Tambahkan import ini


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,

      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String adminHomeRoute = '/admin_home_screen';
  static const String kelolaPenumpangRoute = '/kelola_penumpang_screen';
  static const String kelolaBusRoute = '/kelola_bus_screen';
  static const String detailPenumpangRoute = '/detail_penumpang_screen';
  static const String pemesananManualRoute = '/pemesanan_manual_screen'; // Tambahkan route ini
  

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Admin Paners',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F6FA),
            primaryColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              systemOverlayStyle: SystemUiOverlayStyle.dark,
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
            adminHomeRoute: (context) => AdminHomeScreen(),
            kelolaPenumpangRoute: (context) => KelolaPenumpangScreen(),
            kelolaBusRoute: (context) => KelolaBusScreen(),
            detailPenumpangRoute: (context) => DetailPenumpangScreen(pemesanan: ModalRoute.of(context)!.settings.arguments as dynamic),
            pemesananManualRoute: (context) => const PemesananManualScreen(), // Daftarkan halaman baru
          },
        );
      },
    );
  }
}