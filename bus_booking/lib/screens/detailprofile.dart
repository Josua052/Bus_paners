import 'dart:io'; // Keep if you use it for profile pic selection, otherwise remove
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import GoogleFonts
import 'package:intl/intl.dart'; // Import for date formatting

class DetailProfileScreen extends StatefulWidget {
  const DetailProfileScreen({super.key});

  @override
  State<DetailProfileScreen> createState() => _DetailProfileScreenState();
}

class _DetailProfileScreenState extends State<DetailProfileScreen> {
  // --- Start of essential state variables for user profile data ---
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController(); // Renamed from dateController for clarity
  String? selectedGender;
  bool isModified = false;

  // These variables were missing in your last provided code snippet,
  // causing the "getter 'userName' isn't defined" error.
  String? userName; // This was the missing variable
  String? userEmail; // Added to display user's email
  String? profileImageUrl; // For profile image URL if you have it
  // --- End of essential state variables ---

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
      setState(() {
        nameController.text = data?['displayName'] ?? '';
        phoneController.text = data?['phoneNumber'] ?? '';
        dobController.text = data?['tanggal_lahir'] ?? ''; // Assuming 'tanggal_lahir' format is string
        selectedGender = data?['jenis_kelamin'];
        userName = data?['displayName'] ?? 'Pengguna'; // Ensure userName is also populated
        userEmail = user.email; // Get email from FirebaseAuth
        profileImageUrl = data?['profileImageUrl']; // Asumsi Anda menyimpan URL gambar di Firestore
      });
    }
  }

  Future<void> updateUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'displayName': nameController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'tanggal_lahir': dobController.text.trim(),
          'jenis_kelamin': selectedGender,
        });
        if (mounted) { // Check if widget is still mounted before showing SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Perubahan berhasil disimpan!", style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
          setState(() => isModified = false); // Reset isModified after successful save
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan perubahan: $e", style: GoogleFonts.poppins()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void checkIfModified() {
    // This function will be called on any text field change or gender selection
    // A more robust check would compare current values with initial fetched values
    // but for simplicity, we just set it to true when any change occurs.
    if (!isModified) {
      setState(() {
        isModified = true;
      });
    }
  }

  // --- Widget Kustom untuk TextField yang Modern ---
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      onChanged: (_) => checkIfModified(), // Memanggil checkIfModified saat ada perubahan
      enabled: !readOnly, // Nonaktifkan jika readOnly
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15.sp), // Gaya teks input
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 15.sp),
        prefixIcon: Icon(icon, color: const Color(0xFF265AA5)),
        filled: true,
        fillColor: Colors.grey.shade100, // Background field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none, // Default tanpa border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0), // Border saat tidak aktif
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: const Color(0xFF265AA5), width: 2.0), // Border saat fokus
        ),
        suffixIcon: onTap != null ? Icon(Icons.arrow_drop_down, color: Colors.grey.shade600) : null, // Panah drop-down untuk date picker
      ),
    );
  }
  // --- End Widget Kustom ---

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion masih diperlukan di sini untuk mengatur gaya status/navigation bar secara spesifik untuk halaman ini.
    // Jika AppBar Anda gelap, status bar ikon harus terang. Navigation bar putih ikon gelap.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF265AA5), // Background Status Bar BIRU GELAP
        statusBarIconBrightness: Brightness.light, // Ikon Status Bar PUTIH
        statusBarBrightness: Brightness.dark,      // Untuk iOS: teks putih

        systemNavigationBarColor: Colors.white, // Background Navigation Bar PUTIH
        systemNavigationBarIconBrightness: Brightness.dark, // Ikon Navigation Bar HITAM
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA), // Background Scaffold sesuai tema global (terang)
        appBar: AppBar(
          title: Text(
            'Informasi Akun',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF265AA5), // AppBar biru gelap
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white), // Ikon back putih
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            statusBarIconBrightness: Brightness.light, // Ikon status bar putih
            statusBarBrightness: Brightness.dark,      // iOS
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h), // Padding konsisten
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the avatar and name
            children: [
              // --- Header Profil (Re-desain) ---
              CircleAvatar(
                radius: 50.r,
                backgroundColor: Colors.grey.shade200, // Warna background avatar
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!) // Load from network if URL exists
                    : null,
                child: profileImageUrl == null || profileImageUrl!.isEmpty
                    ? Icon(Icons.person, size: 60.sp, color: Colors.grey.shade600) // Icon default
                    : null,
              ),
              SizedBox(height: 16.h),
              Text(
                userName ?? 'Pengguna', // userName is now defined in State
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (userEmail != null) // Tampilkan email jika ada
                Text(
                  userEmail!,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 30.h), // Spasi setelah header profil

              // --- Form Informasi ---
              _buildModernTextField(
                controller: nameController,
                labelText: "Nama Lengkap",
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),
              _buildModernTextField(
                controller: phoneController,
                labelText: "Nomor Telepon",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 16.h),
              _buildModernTextField(
                controller: dobController,
                labelText: "Tanggal Lahir",
                icon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: dobController.text.isNotEmpty
                        ? DateFormat('dd/MM/yyyy').parse(dobController.text)
                        : DateTime.now(), // Menggunakan initialDate dari controller
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) { // Theme untuk DatePicker
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF265AA5), // Header background
                            onPrimary: Colors.white,   // Header text color
                            surface: Colors.white,     // Calendar background
                            onSurface: Colors.black,   // Calendar text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF265AA5), // OK/Cancel button color
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    dobController.text = DateFormat('dd/MM/yyyy').format(picked);
                    checkIfModified();
                  }
                },
              ),
              SizedBox(height: 20.h),

              // --- Jenis Kelamin (Modernized) ---
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Jenis Kelamin",
                  style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text("Laki-laki", style: GoogleFonts.poppins(
                        color: selectedGender == "Laki-laki" ? Colors.white : Colors.black87,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      )),
                      selected: selectedGender == "Laki-laki",
                      selectedColor: const Color(0xFF265AA5), // Warna saat dipilih
                      backgroundColor: Colors.grey.shade100, // Warna saat tidak dipilih
                      onSelected: (bool selected) {
                        setState(() {
                          selectedGender = selected ? "Laki-laki" : null;
                          checkIfModified();
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: selectedGender == "Laki-laki" ? const Color(0xFF265AA5) : Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ChoiceChip(
                      label: Text("Perempuan", style: GoogleFonts.poppins(
                        color: selectedGender == "Perempuan" ? Colors.white : Colors.black87,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      )),
                      selected: selectedGender == "Perempuan",
                      selectedColor: const Color(0xFF265AA5),
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedGender = selected ? "Perempuan" : null;
                          checkIfModified();
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: selectedGender == "Perempuan" ? const Color(0xFF265AA5) : Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
                    // isModified diset false di updateUserData setelah berhasil
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
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}