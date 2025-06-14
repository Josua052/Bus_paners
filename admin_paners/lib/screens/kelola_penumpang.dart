import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'detail_penumpang.dart';
import 'admin_home_screen.dart';
import 'kelola_bus.dart';

class KelolaPenumpangScreen extends StatefulWidget {
  const KelolaPenumpangScreen({super.key});

  @override
  State<KelolaPenumpangScreen> createState() => _KelolaPenumpangScreenState();
}

class _KelolaPenumpangScreenState extends State<KelolaPenumpangScreen> {
  DateTime? selectedDate;
  String? formattedDate;

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4695),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D4695)),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20.sp),
                ),
              ),
            ),
            _drawerItem(context, Icons.home, 'Beranda', () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminHomeScreen()));
            }),
            _drawerItem(context, Icons.directions_bus, 'Kelola Bus', () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => KelolaBusScreen()));
            }),
            _drawerItem(context, Icons.people, 'Penumpang', () {
              Navigator.pop(context);
            }, active: true),
          ],
        ),
      ),
      body: SafeArea(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, child) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "List Pemesanan Bus",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset('assets/images/identitas_logo.png', height: 100.h),
              TextButton(
                onPressed: _pickDate,
                child: Text(
                  formattedDate ?? 'Pilih Tanggal',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
                ),
              ),
              Divider(
                thickness: 1,
                indent: 60.w,
                endIndent: 60.w,
                color: Colors.white70,
              ),
              SizedBox(height: 8.h),

              ElevatedButton(
                onPressed: () => setState(() {}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD100),
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                ),
                child: Text("Cari", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pemesanan')
                      .where('tanggal', isEqualTo: formattedDate ?? '')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "Tidak ada pemesanan",
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp),
                        ),
                      );
                    }
                    return ListView(
                      padding: EdgeInsets.all(16.w),
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon
                              SizedBox(
                                width: 40.w,
                                height: 40.h,
                                child: Image.asset('assets/icons/ticket.png'),
                              ),
                              SizedBox(width: 12.w),

                              // Kolom teks, Flexible agar tidak mengambil semua ruang
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(data['nama'] ?? '-', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                    Text('${data['asal']} - ${data['tujuan']}', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                    Text(data['tanggal'] ?? '', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                    Text('Dipesan : ${data['jumlah_kursi'] ?? '..'}', style: GoogleFonts.poppins(fontSize: 12.sp)),
                                    Row(
                                      children: [
                                        Text('Status: ', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500)),
                                        Text(
                                          data['status'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: data['status'] == 'Terverifikasi'
                                                ? Colors.green
                                                : data['status'] == 'Menunggu Konfirmasi'
                                                    ? const Color(0xFFFFD100)
                                                    : Colors.red,
                                          ),
                                        ),

                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Tombol Detail diatur agar fleksibel
                              Flexible(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => DetailPenumpangScreen(pemesanan: doc),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'Detail',
                                      style: GoogleFonts.poppins(
                                        color: Colors.black87,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                        );
                      }).toList(),
                    );

                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool active = false}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: active ? Colors.blue : Colors.black),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: active ? Colors.blue : Colors.black,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
