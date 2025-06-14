import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool showText = false;
  late AnimationController _logoController;
  late Animation<Offset> _logoOffset;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _logoOffset = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.2),
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    Timer(Duration(seconds: 2), () {
      _logoController.forward();
      setState(() {
        showText = true;
      });
    });

    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE5F1FF),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ScreenUtilInit(
            designSize: Size(375, 812),
            builder: (_, child) => Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/bg_app.jpg',
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Color.fromRGBO(229, 241, 255, 0.9),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SlideTransition(
                        position: _logoOffset,
                        child: Column(
                          children: [
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/logo_app.png'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Admin Panel',
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0D4695),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showText) ...[
                        SizedBox(height: 30.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                              'Kelola Data dan Pemesanan dengan Mudah',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                        ),
                        SizedBox(height: 12.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.w),
                          child: Text(
                            'Selamat Bekerja.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
