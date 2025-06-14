import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PembayaranScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal; // format: "11 Jun 2025"
  final String jam; // format: "16:30"
  final String nama;
  final String telepon;
  final int jumlahKursi;
  final List<int> kursiDipilih;
  final int totalPembayaran;
  final String kelas;

  const PembayaranScreen({
    Key? key,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
    required this.jam,
    required this.nama,
    required this.telepon,
    required this.jumlahKursi,
    required this.kursiDipilih,
    required this.totalPembayaran,
    required this.kelas,
  }) : super(key: key);

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String metodePembayaran = 'COD';

  String generateKodePemesanan() {
    String inisialAsal = widget.asal.substring(0, 2).toUpperCase();
    String inisialTujuan = widget.tujuan.substring(0, 2).toUpperCase();
    String tanggal = widget.tanggal.substring(0, 2); // "11"
    String jam = widget.jam.split(":")[0].padLeft(2, '0'); // "16"
    String kursi = widget.jumlahKursi.toString().padLeft(
      2,
      '0',
    ); // "01" misalnya
    return "$inisialAsal$inisialTujuan$tanggal$jam$kursi";
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, child) => Scaffold(
            backgroundColor: const Color(0xFF265AA5),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(color: Colors.white),
              title: const Text(
                "Pembayaran",
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "${widget.asal} → ${widget.tujuan}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.jam,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          widget.kelas,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          widget.tanggal,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          "Detail Penumpang",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Nama: ${widget.nama}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "Nomor Telepon: ${widget.telepon}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Kursi Dipilih: ${widget.kursiDipilih.toList()..sort()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          "Total Pembayaran: Rp ${widget.totalPembayaran}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text(
                            "Cash on Delivery",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value: 'COD',
                          groupValue: metodePembayaran,
                          onChanged:
                              (value) =>
                                  setState(() => metodePembayaran = value!),
                        ),
                        RadioListTile<String>(
                          title: const Text(
                            "Transfer Bank",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          value: 'Transfer',
                          groupValue: metodePembayaran,
                          onChanged:
                              (value) =>
                                  setState(() => metodePembayaran = value!),
                        ),
                        if (metodePembayaran == 'Transfer')
                          Padding(
                            padding: EdgeInsets.only(top: 12.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Text(
                                  "Kode Pemesanan Anda:",
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  generateKodePemesanan(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF265AA5),
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  "Silakan transfer ke rekening BANK ABC 1234567890 Gunakan kode ini sebagai berita transfer.",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final kode = generateKodePemesanan();
                                      final currentUser =
                                          FirebaseAuth.instance.currentUser;
                                      final data = {
                                        'uid': currentUser?.uid ?? '',
                                        'asal': widget.asal,
                                        'tujuan': widget.tujuan,
                                        'tanggal': widget.tanggal,
                                        'jam': widget.jam,
                                        'kelas': widget.kelas,
                                        'nama': widget.nama,
                                        'telepon': widget.telepon,
                                        'jumlah_kursi': widget.jumlahKursi,
                                        'kode_pemesanan': kode,
                                        'metode_pembayaran': metodePembayaran,
                                        'status': 'Menunggu Konfirmasi',
                                        'kursi': widget.kursiDipilih.toList(),
                                        'dipesan_pada': Timestamp.now(),
                                        'total_pembayaran':
                                            widget
                                                .totalPembayaran, // opsional, ubah sesuai implementasi
                                      };

                                      await FirebaseFirestore.instance
                                          .collection('pemesanan')
                                          .add(data);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Silahkan menunggu konfirmasi dari admin",
                                          ),
                                        ),
                                      );

                                      await Future.delayed(
                                        Duration(seconds: 2),
                                      );

                                      Navigator.of(
                                        context,
                                      ).pushNamedAndRemoveUntil(
                                        '/home',
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 14.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Verifikasi Sekarang",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (metodePembayaran == 'COD')
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final kode = generateKodePemesanan();
                                  final currentUser =
                                      FirebaseAuth.instance.currentUser;
                                  final data = {
                                    'uid': currentUser?.uid ?? '',
                                    'asal': widget.asal,
                                    'tujuan': widget.tujuan,
                                    'tanggal': widget.tanggal,
                                    'jam': widget.jam,
                                    'nama': widget.nama,
                                    'telepon': widget.telepon,
                                    'jumlah_kursi': widget.jumlahKursi,
                                    'kode_pemesanan': kode,
                                    'metode_pembayaran': metodePembayaran,
                                    'status': 'Menunggu Konfirmasi',
                                    'kursi': widget.kursiDipilih.toList(),
                                    'dipesan_pada': Timestamp.now(),
                                    'total_pembayaran': widget.totalPembayaran,
                                  };

                                  await FirebaseFirestore.instance
                                      .collection('pemesanan')
                                      .add(data);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Tunjukkan bukti pemesanan ke admin bus di terminal untuk verifikasi pembayaran",
                                      ),
                                    ),
                                  );

                                  await Future.delayed(Duration(seconds: 2));

                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/home',
                                    (route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  "Konfirmasi",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
