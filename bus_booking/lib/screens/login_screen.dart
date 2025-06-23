import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'signup.dart';
import 'lupa_password.dart'; // Import halaman lupa_password.dart

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showPassword = false;
  bool isLoading = false;

  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan Password wajib diisi')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ✅ LANGKAH 1: Login ke Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      // ✅ LANGKAH 2: Ambil data pengguna dari koleksi 'users' di Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users') // Cek koleksi 'users'
          .doc(uid)
          .get();

      // ✅ LANGKAH 3: Periksa apakah dokumen pengguna ada dan memiliki role 'user'
      if (!userDoc.exists) {
        // Jika dokumen tidak ada di koleksi 'users'
        await FirebaseAuth.instance.signOut(); // Logout pengguna dari Firebase Auth
        throw 'Akun tidak terdaftar sebagai pengguna. Silakan daftar atau hubungi dukungan.';
      }

      final role = userDoc.data()?['role'];
      if (role != 'user') {
        // Jika dokumen ada tapi role bukan 'user' (misal 'admin')
        await FirebaseAuth.instance.signOut(); // Logout pengguna
        throw 'Akun ini tidak memiliki akses ke aplikasi pengguna.';
      }

      // ✅ LANGKAH 4: Arahkan ke halaman HomeScreen jika semua validasi berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat login';
      if (e.code == 'user-not-found') {
        errorMessage = 'Akun dengan email ini tidak ditemukan.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Password salah.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Terlalu banyak percobaan login. Silakan coba lagi nanti.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red), // Tambahkan warna merah untuk error
      );
    } catch (e) {
      // Tangani error dari `throw` di atas atau error tak terduga lainnya
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack( // ScreenUtilInit di main.dart sudah cukup, ini bisa dihapus dari sini
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Image.asset(
              'assets/images/bg_app.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          ),
          Container(
            color: const Color.fromRGBO(229, 241, 255, 0.9),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_app.png',
                    width: 150.w,
                    height: 150.w,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "Hai Paners",
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Silahkan masukkan email dan password kamu untuk masuk",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.email, color: Colors.grey.shade700),
                      hintText: "Enter Email",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Color(0xFF265AA5), width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade700),
                      suffixIcon: IconButton(
                        icon: Icon(
                          showPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                      ),
                      hintText: "Enter Password",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: Color(0xFF265AA5), width: 2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: showPassword,
                            onChanged: (value) {
                              setState(() {
                                showPassword = value ?? false;
                              });
                            },
                          ),
                          Text("Tampilkan Sandi", style: GoogleFonts.poppins(fontSize: 13.sp)),
                        ],
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Lupa Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LupaPasswordScreen()),
                              );
                            },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD100),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.black)
                          : Text(
                                "MASUK",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text.rich(
                    TextSpan(
                      text: 'Belum memiliki akun? ',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: 'Buat Akun',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignupScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}