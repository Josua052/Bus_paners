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

  if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty || confirm.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Semua kolom wajib diisi")),
    );
    return;
  }

  if (pass != confirm) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Konfirmasi kata sandi tidak cocok")),
    );
    return;
  }

  if (pass.length < 8) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Kata sandi minimal 8 karakter")),
    );
    return;
  }

  setState(() {
    isLoading = true;
  });

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: pass);

    final uid = userCredential.user!.uid;

    // Simpan data user ke Firestore dengan role = user
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': name,
      'email': email,
      'phoneNumber': phone,
      'role': 'user', // 👈 inilah yang membedakan
      'createdAt': FieldValue.serverTimestamp(),
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Sukses'),
        content: Text('Akun berhasil dibuat!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Future.microtask(() {
                Navigator.pushReplacementNamed(context, '/login');
              });
            },
            child: Text('OK'),
          ),
        ],
      ),
    );

  } on FirebaseAuthException catch (e) {
    String message = 'Terjadi kesalahan saat mendaftar';
    if (e.code == 'email-already-in-use') {
      message = 'Email sudah terdaftar';
    } else if (e.code == 'weak-password') {
      message = 'Kata sandi terlalu lemah';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    debugPrint("Error saat signup: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Terjadi kesalahan saat membuat akun. Silakan coba lagi.")),
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
        builder: (_, child) => Stack(
          children: [
            Transform.scale(
              scale: 1.2,
              child: Image.asset(
                'assets/images/bg_app.jpg',
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Container(color: Color.fromRGBO(229, 241, 255, 0.9)),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Column(
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
                    _inputField(controller: nameController, hint: "Nama lengkap"),
                    SizedBox(height: 12.h),
                    _inputField(
                      controller: emailController,
                      hint: "Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 12.h),
                    _inputField(
                      controller: phoneController,
                      hint: "Nomor telepon",
                      keyboardType: TextInputType.phone,
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
                          backgroundColor: Color(0xFFFFD100),
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
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

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
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        suffixIcon: IconButton(
          icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
          onPressed: toggle,
        ),
      ),
    );
  }
}
