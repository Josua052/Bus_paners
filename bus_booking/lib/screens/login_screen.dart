import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'home_screen.dart';
import 'signup.dart';

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
    // Login ke Firebase
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final uid = userCredential.user!.uid;

    // Ambil data dari Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (!userDoc.exists) {
      throw 'Data pengguna tidak ditemukan di Firestore.';
    }

    final role = userDoc.data()?['role'];
    if (role != 'user') {
      await FirebaseAuth.instance.signOut();
      throw 'Akun ini tidak memiliki akses ke aplikasi pengguna.';
    }

    // Arahkan ke halaman HomeScreen
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
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }

  setState(() {
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ScreenUtilInit(
        designSize: Size(375, 812),
        builder: (context, child) => Stack(
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
              color: Color.fromRGBO(229, 241, 255, 0.9),
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
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        hintText: "Enter Email",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword, // Perubahan di sini
                      decoration: InputDecoration(
                        hintText: "Enter Password",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
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
                            Text("Tampilkan Sandi", style: GoogleFonts.poppins(fontSize: 13.sp)), // Ganti label
                          ],
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
      ),
    );
  }
}
