import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'pesan_tiket_screen.dart';
import 'informasi_jadwal_bus.dart';
import 'login_screen.dart';
import 'detailprofile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  String? userName;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      setState(() {
        userName = data?['displayName'] ?? 'Pengguna';
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PesanTiketScreen()),
        );
        break;
      case 2:
        break;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "Yakin ingin keluar?",
              style: TextStyle(fontSize: 16.sp, fontFamily: 'Poppins'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Tidak",
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD100),
                  foregroundColor: Color(0xFF265AA5),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: Text("Iya", style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (context, child) => Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                title: Text(
                  'Profil',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFF265AA5),
                elevation: 0,
                automaticallyImplyLeading: false,
                iconTheme: const IconThemeData(color: Colors.white),
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          userName ?? 'Pengguna',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ),
                    _menuItem(Icons.person, 'Informasi Pribadi', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailProfileScreen(),
                        ),
                      );
                    }),
                    Divider(),
                    _menuItem(Icons.lock, 'Ganti Kata Sandi', () {}),
                    Divider(),
                    _menuItem(Icons.help_outline, 'Pusat Bantuan', () {}),
                    Divider(),
                    _menuItem(Icons.info_outline, 'Tentang Bus Booking', () {}),
                    Divider(),
                    _menuItem(
                      Icons.logout,
                      'Keluar',
                      _showLogoutConfirmation,
                      showArrow: false,
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: const Color(0xFF265AA5),
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.confirmation_num),
                    label: 'Tiket',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF265AA5)),
      title: Text(label),
      trailing:
          showArrow ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
      horizontalTitleGap: 0,
    );
  }
}
