import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key});

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedGender;
  bool isModified = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        nameController.text = data['displayName'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        dateController.text = data['tanggal_lahir'] ?? '';
        selectedGender = data['jenis_kelamin'];
        setState(() {}); // trigger UI update
      }
    }
  }

  Future<void> updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'displayName': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'tanggal_lahir': dateController.text.trim(),
        'jenis_kelamin': selectedGender,
      });
    }
  }

  void checkIfModified() {
    setState(() {
      isModified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF6F5F9),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFFF6F5F9),
            iconTheme: const IconThemeData(color: Colors.black),
            title: Text(
              "Informasi Akun",
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Lengkapi informasi data diri anda",
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: phoneController,
                  onChanged: (_) => checkIfModified(),
                  decoration: InputDecoration(
                    labelText: "No. Telepon",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: nameController,
                  onChanged: (_) => checkIfModified(),
                  decoration: InputDecoration(
                    labelText: "Nama Lengkap",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      dateController.text =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                      checkIfModified();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Tanggal Lahir",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                SizedBox(height: 24.h),
                Text("Jenis Kelamin", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Laki-laki"),
                        value: "Laki-laki",
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            checkIfModified();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text("Perempuan"),
                        value: "Perempuan",
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                            checkIfModified();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: isModified
              ? Container(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h + MediaQuery.of(context).padding.bottom),
                  color: Colors.white,
                  child: ElevatedButton(
                    onPressed: () async {
                      await updateUserData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Perubahan disimpan")),
                      );
                      setState(() => isModified = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      "Simpan Perubahan",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
