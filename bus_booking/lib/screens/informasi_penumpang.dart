import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'pembayaran.dart'; // Pastikan path ini benar

class InformasiPenumpangScreen extends StatefulWidget {
  final String dari;
  final String tujuan;
  final String waktu;
  final Set<int> selectedSeats;
  final int hargaTiketPerKursi;
  final String kelas;

  const InformasiPenumpangScreen({
    Key? key,
    required this.dari,
    required this.tujuan,
    required this.waktu,
    required this.selectedSeats,
    required this.hargaTiketPerKursi,
    required this.kelas,
  }) : super(key: key);

  @override
  State<InformasiPenumpangScreen> createState() =>
      _InformasiPenumpangScreenState();
}

class _InformasiPenumpangScreenState extends State<InformasiPenumpangScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool agreedTerms = false;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setSystemUIOverlayStyle removed as per previous update.
    // It will now follow the global settings from main.dart
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Widget _textField({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final OutlineInputBorder whiteBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: const BorderSide(color: Colors.white, width: 1.0),
    );

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        border: whiteBorder,
        enabledBorder: whiteBorder,
        focusedBorder: whiteBorder,
        errorBorder: whiteBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: whiteBorder.copyWith(borderSide: const BorderSide(color: Colors.red)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint wajib diisi";
        }
        if (hint.toLowerCase().contains('email')) {
          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
            return "Email tidak valid";
          }
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalHarga = widget.hargaTiketPerKursi * widget.selectedSeats.length;
    List<int> sortedSeats = widget.selectedSeats.toList()..sort();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) =>
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
              // systemOverlayStyle ini memastikan ikon status bar hitam saat AppBar putih ini aktif.
              systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ),
              title: Text(
                "Informasi Penumpang",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body:
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "${widget.dari} → ${widget.tujuan}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                            ),
                            Builder(
                              builder: (_) {
                                final waktuParts = widget.waktu.split(" ");
                                String tanggal = '';
                                String jam = '';

                                if (waktuParts.length >= 3) {
                                  tanggal = waktuParts
                                      .sublist(0, 3)
                                      .join(" ");
                                } else {
                                  tanggal = widget.waktu;
                                }

                                if (waktuParts.length >= 4) {
                                  jam = waktuParts[3];
                                }

                                return Text(
                                  jam.isNotEmpty
                                      ? "$tanggal | $jam"
                                      : tanggal,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                );
                              },
                            ),
                            Text(
                              widget.kelas,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Expanded(
                        // Start of new code: Add GestureDetector to dismiss keyboard on tap outside
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus(); // Dismiss keyboard
                          },
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0D4695), // Background box tetap biru gelap
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Detail Penumpang",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: Colors.white, // Warna teks menjadi putih
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        _textField(
                                          hint: "Nama",
                                          controller: nameController,
                                        ),
                                        SizedBox(height: 12.h),
                                        _textField(
                                          hint: "Nomor Telepon",
                                          controller: phoneController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: agreedTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            agreedTerms = value ?? false;
                                          });
                                        },
                                      ),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14.sp,
                                            ),
                                            children: [
                                              const TextSpan(
                                                text:
                                                    "Saya telah membaca dan setuju terhadap ",
                                              ),
                                              TextSpan(
                                                text:
                                                    "Syarat dan ketentuan pembelian tiket",
                                                style: const TextStyle(
                                                  decoration: TextDecoration.underline,
                                                  color: Color(0xFF265AA5),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // End of new code: Add GestureDetector to dismiss keyboard on tap outside
                      ),
                    ],
                  ),
                ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.fromLTRB(
                24.w,
                16.h,
                24.w,
                16.h + MediaQuery.of(context).padding.bottom,
              ),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Start of updated code for price and seat info alignment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                    children: [ // Use children directly in Row to avoid extra Flexible/Expanded if possible
                      Text(
                        "Rp ${NumberFormat('#,###', 'id_ID').format(totalHarga)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      // Spacer will push the elements to the ends
                      const Spacer(),
                      // Ensure "Kursi ke" and the seat numbers are grouped
                      Row(
                        mainAxisSize: MainAxisSize.min, // Keep this row minimal
                        children: [
                          Text(
                            "Kursi ke ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          // Use a Flexible or Expanded with overflow handling for seat numbers
                          Flexible( // Flexible is better than SizedBox for dynamic width
                            child: Text(
                              sortedSeats.join(", "),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                              overflow: TextOverflow.ellipsis, // Use ellipsis for overflow
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // End of updated code for price and seat info alignment
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!agreedTerms) return;

                        final isValid =
                            _formKey.currentState?.validate() ?? false;
                        if (isValid) {
                          final waktuParts = widget.waktu.split(" ");
                          final tanggal = waktuParts
                              .sublist(0, 3)
                              .join(" "); // "11 Jun 2025"
                          final jam =
                              waktuParts.length > 3
                                  ? waktuParts[3]
                                  : ''; // "13:16"

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => PembayaranScreen(
                                    asal: widget.dari,
                                    tujuan: widget.tujuan,
                                    tanggal: tanggal,
                                    jam: jam,
                                    nama: nameController.text,
                                    telepon: phoneController.text,
                                    jumlahKursi: widget.selectedSeats.length,
                                    kursiDipilih:
                                        widget.selectedSeats.toList(),
                                    totalPembayaran: totalHarga,
                                    kelas: widget.kelas,
                                  ),
                            ),
                          );
                        }
                      },

                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((
                              states,
                            ) {
                              return const Color(0xFFFFC107);
                            }),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                      ),
                      child: Text(
                        "Bayar Sekarang",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}