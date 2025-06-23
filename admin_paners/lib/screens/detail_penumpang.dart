import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPenumpangScreen extends StatelessWidget {
  final DocumentSnapshot pemesanan;

  const DetailPenumpangScreen({super.key, required this.pemesanan});

  @override
  Widget build(BuildContext context) {
    final data = pemesanan.data() as Map<String, dynamic>;
    final int jumlah = data['jumlah_kursi'] ?? 0;
    final int harga = 120000;
    final int total = jumlah * harga;
    final String currentStatus = data['status'] ?? '';

    return Scaffold( // Scaffold is now the root widget
      backgroundColor: const Color(0xFF0D4695),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D4695),
        elevation: 0,
        // End of updated code: systemOverlayStyle in AppBar
        title: Text(
          'Detail Pemesanan',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea( // SafeArea is the direct child of Scaffold's body
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    Image.asset("assets/images/bg_app.jpg", width: 80.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${data['asal']} - ${data['tujuan']}", style: GoogleFonts.poppins(fontSize: 14.sp)),
                          Text(data['tanggal'] ?? '', style: GoogleFonts.poppins(fontSize: 13.sp)),
                          Text(data['jam'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("AC", style: GoogleFonts.poppins(color: Colors.amber, fontWeight: FontWeight.bold)),
                        Text("Rp ${harga.toString()}", style: GoogleFonts.poppins()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text("Identitas Penumpang", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 12.h),
              _infoRow("Nama", data['nama']),
              _infoRow("No.Hp", data['telepon']),
              _infoRow("Pilihan Kursi", (data['kursi'] as List<dynamic>).join(", ")),
              SizedBox(height: 20.h),
              Text("Detail Pemesanan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.sp)),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: Column(
                  children: [
                    Image.asset("assets/icons/ticket.png", height: 40.h),
                    SizedBox(height: 12.h),
                    _infoRow("Jumlah Orang", jumlah.toString()),
                    _infoRow("Harga Tiket", "Rp $harga"),
                    _infoRowBold("Total", "Rp $total"),
                    Row(
                      children: [
                        Text("Status: ", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                        Text(
                          currentStatus,
                          style: GoogleFonts.poppins(
                            color: currentStatus == 'Terverifikasi'
                                ? Colors.green
                                : currentStatus == 'Menunggu Konfirmasi'
                                    ? const Color(0xFFFFD100)
                                    : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 90.h),
            ],
          ),
        ),
      ),
      // Start of corrected code: bottomNavigationBar is now directly inside Scaffold
      bottomNavigationBar: currentStatus == 'Menunggu Konfirmasi'
          ? Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + MediaQuery.of(context).padding.bottom),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _updateStatus(context, "Gagal"),
                      child: Text("Batalkan", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () => _updateStatus(context, "Terverifikasi"),
                      child: Text("Konfirmasi", style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )
          : null, // If status is not 'Menunggu Konfirmasi', bottomNavigationBar will be null (not displayed)
      // End of corrected code: bottomNavigationBar
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.poppins(color: Colors.white))),
          Text(":", style: GoogleFonts.poppins(color: Colors.white)),
          Expanded(flex: 3, child: Text(value ?? '-', style: GoogleFonts.poppins(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _infoRowBold(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
          Text(":", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String statusBaru) async {
    await FirebaseFirestore.instance.collection('pemesanan').doc(pemesanan.id).update({'status': statusBaru});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status diperbarui menjadi $statusBaru")),
    );
    Navigator.pop(context);
  }
}