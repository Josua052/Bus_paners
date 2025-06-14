import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_bus.dart';
import 'kelola_penumpang.dart';
import 'admin_home_screen.dart';
import 'detail_bus.dart';
import 'package:intl/intl.dart';

class KelolaBusScreen extends StatelessWidget {
  const KelolaBusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D4695),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF0D4695)),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
            _drawerItem(context, Icons.home, 'Beranda', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AdminHomeScreen()),
              );
            }),
            _drawerItem(context, Icons.directions_bus, 'Kelola Bus', () {
              Navigator.pop(context); // Tetap di halaman ini
            }, active: true),
            _drawerItem(context, Icons.people, 'Penumpang', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => KelolaPenumpangScreen()),
              );
            }),
          ],
        ),
      ),
      body: SafeArea(
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (_, child) => Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        Builder(
                          builder:
                              (context) => IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Colors.white,
                                ),
                                onPressed:
                                    () => Scaffold.of(context).openDrawer(),
                              ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "List Bus",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/identitas_logo.png',
                    height: 100.h,
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('buses')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "Tidak Ada Data Bus",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        final buses = snapshot.data!.docs;

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: buses.length,
                          itemBuilder: (context, index) {
                            final bus = buses[index];
                            final asal = bus['asal'] ?? '';
                            final tujuan = bus['tujuan'] ?? '';
                            final List<dynamic> tanggalList = List.from(bus['tanggal'] ?? []);
                            final jamStr = bus['jam'] ?? '';

                            String tanggal = '-';

                            if (tanggalList.isNotEmpty) {
                              final firstTanggal = tanggalList.first; // misal "11 Jun 2025"
                              final DateTime now = DateTime.now();

                              try {
                                final DateTime keberangkatan = DateFormat("dd MMM yyyy HH:mm")
                                    .parse("$firstTanggal $jamStr");

                                if (now.isAfter(keberangkatan)) {
                                  // Sudah lewat waktunya, hapus tanggal pertama
                                  tanggalList.removeAt(0);
                                  // Update ke Firestore
                                  FirebaseFirestore.instance
                                      .collection('buses')
                                      .doc(bus.id)
                                      .update({'tanggal': tanggalList});
                                }

                                tanggal = tanggalList.isNotEmpty ? tanggalList.first : '-';

                              } catch (e) {
                                print("Format tanggal salah: $e");
                              }
                            }

                            final kelas = bus['kelas'] ?? '';
                            final biaya = bus['biaya'] ?? '';

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => DetailBusScreen(
                                          busId: bus.id,
                                          busData:
                                              bus.data()
                                                  as Map<String, dynamic>,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16.h),
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.asset(
                                        'assets/images/bg_app.jpg',
                                        width: 60.w,
                                        height: 60.w,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$asal - $tujuan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            tanggal,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13.sp,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Text(
                                            jamStr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          kelas,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFFD100),
                                          ),
                                        ),
                                        Text(
                                          "Rp ${biaya.toString()}",
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahBusScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD100),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Tambah Bus",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 16.sp,
                          ),
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

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) {
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
