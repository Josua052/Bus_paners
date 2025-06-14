import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/pesan_tiket_screen.dart';
import '../screens/info_keberangkatan_screen.dart';

class AppRoutes {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String pesanTiketRoute = '/pesan_tiket';
  static const String infoKeberangkatanRoute = '/info_keberangkatan';

  static final Map<String, WidgetBuilder> routes = {
    splashRoute: (context) => SplashScreen(),
    loginRoute: (context) => LoginScreen(),
    homeRoute: (context) => HomeScreen(),
    pesanTiketRoute: (context) => PesanTiketScreen(),
    infoKeberangkatanRoute: (context) => InfoKeberangkatanScreen(),
  };
}
