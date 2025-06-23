import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int _selectedIndex = 2; // For BottomNavigationBar
  String? userName;
  String? userEmail;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    // SystemChrome.setSystemUIOverlayStyle dihapus dari sini karena akan diatur di AnnotatedRegion pada build()
    // atau di AppBar, memastikan kontrol per-layar.
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        userName = data?['displayName'] ?? 'Pengguna';
        userEmail = user.email;
        profileImageUrl = data?['profileImageUrl'];
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
        // Already on Profile screen, do nothing
        break;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          "Konfirmasi Keluar",
          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin keluar dari akun ini?",
          style: GoogleFonts.poppins(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Tidak",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD100),
              foregroundColor: const Color(0xFF265AA5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            child: Text("Ya, Keluar", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Start of corrected SystemUiOverlayStyle for ProfileScreen
    // Memastikan status bar berwarna biru gelap dengan ikon putih,
    // dan navigation bar berwarna putih dengan ikon hitam.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF265AA5), // Background Status Bar BIRU GELAP
        statusBarIconBrightness: Brightness.light, // Ikon Status Bar PUTIH
        statusBarBrightness: Brightness.dark,      // Untuk iOS: teks putih

        systemNavigationBarColor: Colors.white, // Background Navigation Bar PUTIH
        systemNavigationBarIconBrightness: Brightness.dark, // Ikon Navigation Bar HITAM
      ),
      // End of corrected SystemUiOverlayStyle for ProfileScreen
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: Text(
            'Profil Pengguna',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF265AA5),
          elevation: 0,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white),
          // systemOverlayStyle di AppBar akan menimpa pengaturan statusBar pada AnnotatedRegion
          // jika statusBarColor di AppBar tidak transparan.
          // Karena AppBar ini gelap, kita ingin ikon status bar putih.
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarIconBrightness: Brightness.light, // Ikon status bar putih
            statusBarBrightness: Brightness.dark,      // iOS
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // --- Header Profil Baru ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF265AA5), // Background biru gelap
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : null,
                      child: profileImageUrl == null || profileImageUrl!.isEmpty
                          ? Icon(Icons.person, size: 60.sp, color: const Color(0xFF265AA5))
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      userName ?? 'Pengguna',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 22.sp,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (userEmail != null)
                      Text(
                        userEmail!,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              // --- End Header Profil Baru ---

              SizedBox(height: 24.h),

              // --- Menu Item Cards ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    _buildProfileCardItem(
                      icon: Icons.person_outline,
                      label: 'Informasi Pribadi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DetailProfileScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildProfileCardItem(
                      icon: Icons.lock_outline,
                      label: 'Ganti Kata Sandi',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fitur Ganti Kata Sandi akan datang!')),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildProfileCardItem(
                      icon: Icons.help_outline,
                      label: 'Pusat Bantuan',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fitur Pusat Bantuan akan datang!')),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildProfileCardItem(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fitur Tentang Aplikasi akan datang!')),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    _buildProfileCardItem(
                      icon: Icons.logout,
                      label: 'Keluar',
                      onTap: _showLogoutConfirmation,
                      isLogout: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // Background Bottom Navigation Bar PUTIH
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
    );
  }

  Widget _buildProfileCardItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLogout ? Colors.red.shade600 : const Color(0xFF265AA5),
                size: 24.sp,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: isLogout ? Colors.red.shade600 : Colors.black87,
                  ),
                ),
              ),
              if (!isLogout)
                Icon(Icons.arrow_forward_ios, size: 18.sp, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}