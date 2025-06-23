import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'package:flutter/gestures.dart';


class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false;

  void _signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final pass = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // --- Validasi Input ---
    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi.')),
      );
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kata sandi dan konfirmasi kata sandi tidak cocok.')),
      );
      return;
    }

    // Validasi kekuatan kata sandi (contoh sederhana, bisa disempurnakan)
    if (pass.length < 8 ||
        !pass.contains(RegExp(r'[A-Z]')) ||
        !pass.contains(RegExp(r'[a-z]')) ||
        !pass.contains(RegExp(r'[0-9]')) ||
        !pass.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Kata sandi minimal 8 karakter dengan huruf besar, huruf kecil, angka, dan karakter spesial.'),
        ),
      );
      return;
    }
    // --- End Validasi Input ---

    setState(() {
      isLoading = true;
    });

    try {
      // ✅ LANGKAH 1: Buat akun baru di Firebase Authentication
      // Ini adalah satu-satunya cara untuk membuat akun baru dalam alur pendaftaran.
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      final uid = userCredential.user!.uid;

      // ✅ LANGKAH 2: Simpan data pengguna tambahan ke koleksi 'users' di Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'displayName': name,
        'email': email,
        'phoneNumber': phone,
        'role': 'user', // Secara eksplisit set role sebagai 'user'
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ Tampilkan dialog sukses
      if (mounted) { // Pastikan widget masih mounted sebelum showDialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: Text('Akun Berhasil Dibuat', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            content: Text('Selamat datang di aplikasi Bus Booking, akun Anda telah berhasil didaftarkan!', style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Tutup dialog
                  // Kembali ke halaman Login (dan hapus semua rute sebelumnya)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('OK', style: GoogleFonts.poppins(color: Colors.green)),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Terjadi kesalahan saat mendaftar.';
      if (e.code == 'weak-password') {
        errorMessage = 'Kata sandi terlalu lemah.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Email ini sudah terdaftar. Silakan gunakan email lain atau masuk.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      }
      if (mounted) { // Pastikan widget masih mounted sebelum show SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Error saat signup: $e");
      if (mounted) { // Pastikan widget masih mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan tak terduga saat membuat akun. Silakan coba lagi."), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) { // Pastikan widget masih mounted
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
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
          Container(color: const Color.fromRGBO(229, 241, 255, 0.9)),
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
                  SizedBox(height: 10.h),
                  Text(
                    "Masukkan data diri",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _inputField(controller: nameController, hint: "Nama lengkap", icon: Icons.person_outline),
                  SizedBox(height: 12.h),
                  _inputField(
                    controller: emailController,
                    hint: "Email",
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _inputField(
                    controller: phoneController,
                    hint: "Nomor telepon",
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_android_outlined,
                  ),
                  SizedBox(height: 12.h),
                  _passwordField(
                    controller: passwordController,
                    hint: "Kata Sandi",
                    visible: passwordVisible,
                    toggle: () => setState(() => passwordVisible = !passwordVisible),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        "*Kata sandi minimal 8 karakter dengan huruf besar, huruf kecil, angka dan karakter spesial",
                        style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.black54),
                      ),
                    ),
                  ),
                  _passwordField(
                    controller: confirmPasswordController,
                    hint: "Konfirmasi kata sandi",
                    visible: confirmPasswordVisible,
                    toggle: () => setState(() => confirmPasswordVisible = !confirmPasswordVisible),
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD100),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue.shade900)
                          : Text(
                                "BUAT AKUN",
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text.rich(
                    TextSpan(
                      text: 'Sudah memiliki Akun? ',
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: 'Masuk Akun',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
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

  // Helper widget for general text input fields
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon, // Make icon optional
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade700) : null,
        hintText: hint,
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
          borderSide: BorderSide(color: const Color(0xFF265AA5), width: 2.0),
        ),
      ),
    );
  }

  // Helper widget for password input fields
  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback toggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !visible,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade700),
        hintText: hint,
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
          borderSide: BorderSide(color: const Color(0xFF265AA5), width: 2.0),
        ),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off, color: Colors.grey.shade700),
          onPressed: toggle,
        ),
      ),
    );
  }
}