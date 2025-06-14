import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Dihasilkan oleh `flutterfire configure`

// Import halaman
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pesan_tiket_screen.dart';
import 'screens/info_keberangkatan_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🎨 Atur style sistem UI
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 
  // Daftar route aplikasi
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String pesanTiketRoute = '/pesan_tiket';
  static const String infoKeberangkatanRoute = '/info_keberangkatan';

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Bus Ticket Booking',
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
          ),
          initialRoute: splashRoute,
          routes: {
            splashRoute: (context) => SplashScreen(),
            loginRoute: (context) => LoginScreen(), // ✅ Route untuk LoginScreen
            homeRoute: (context) => HomeScreen(),
            pesanTiketRoute: (context) => PesanTiketScreen(),
            infoKeberangkatanRoute: (context) => InfoKeberangkatanScreen(),
          },
        );
      },
    );
  }
}
