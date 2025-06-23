import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kelola_bus.dart';
import 'package:flutter/services.dart';
import 'kelola_penumpang.dart';
import 'login_screen.dart';
import 'pemesanan_manual_screen.dart'; // Import halaman baru

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  String _getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 3 && hour < 12) {
      return 'Selamat pagi,';
    } else if (hour >= 12 && hour < 16) {
      return 'Selamat siang,';
    } else if (hour >= 16 && hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  String adminName = '';

  @override
  void initState() {
    super.initState();
    _getAdminData();
    // System UI Overlay Style untuk halaman ini (background terang, ikon hitam)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Background status bar putih
        statusBarIconBrightness: Brightness.dark, // Ikon status bar hitam
        statusBarBrightness: Brightness.light, // Untuk iOS
        systemNavigationBarColor: Colors.white, // Navigation bar putih
        systemNavigationBarIconBrightness:
            Brightness.dark, // Ikon navigation bar hitam
      ),
    );
  }

  Future<void> _getAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        adminName = doc.data()?['displayName'] ?? 'Admin';
      });
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun ini?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tidak',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ya',
                style: GoogleFonts.poppins(color: Colors.green),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D4695)),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
            _drawerItem(context, Icons.home, 'Beranda', () {
              Navigator.pop(context);
            }, active: true),
            _drawerItem(context, Icons.directions_bus, 'Kelola Bus', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => KelolaBusScreen()),
              );
            }),
            _drawerItem(context, Icons.people, 'Penumpang', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => KelolaPenumpangScreen()),
              );
            }),
            // Start of new code: Pemesanan Manual in Drawer
            _drawerItem(context, Icons.receipt, 'Pemesanan Manual', () {
              Navigator.pop(context); // Tutup drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PemesananManualScreen()),
              );
            }),
            // End of new code: Pemesanan Manual in Drawer
            Divider(
              thickness: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Colors.grey[300],
            ),
            _drawerItem(context, Icons.logout, 'Sign Out', () {
              Navigator.pop(context);
              _confirmSignOut(context);
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (_, child) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30.h),
                    Row(
                      children: [
                        Builder(
                          builder:
                              (context) => IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.black,
                                ),
                                onPressed:
                                    () => Scaffold.of(context).openDrawer(),
                              ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      adminName,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD100),
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // Start of new code: Pemesanan Manual Button in body
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PemesananManualScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF265AA5,
                        ), // Warna biru untuk pemesanan manual
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Pemesanan Manual",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Teks putih
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // End of new code: Pemesanan Manual Button in body
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KelolaBusScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD100),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Kelola Bus",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KelolaPenumpangScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD100),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            "Kelola Pemesanan Penumpang",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          "“Terima kasih sudah jadi penggerak utama perjalanan ini.\nKerja kerasmu memastikan semua penumpang tiba dengan aman.\nTetap semangat dan terus melaju! 💪✨”",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) {
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
}
