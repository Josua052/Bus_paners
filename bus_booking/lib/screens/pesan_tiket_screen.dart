import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PesanTiketScreen extends StatefulWidget {
  @override
  State<PesanTiketScreen> createState() => _PesanTiketScreenState();
}

class _PesanTiketScreenState extends State<PesanTiketScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        break;
    }
  }

  void _refresh() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Data diperbarui')));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (context, child) => Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  'Perjalanan Saya',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: const Color(0xFF265AA5),
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refresh,
                    tooltip: 'Refresh',
                  ),
                ],
                systemOverlayStyle: SystemUiOverlayStyle.light,
              ),
              body: Padding(
                padding: EdgeInsets.all(24.w),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('pemesanan')
                      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                      .orderBy('dipesan_pada', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/kucing.png',
                            width: 180.w,
                            height: 180.w,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Belum ada Perjalanan.\nAnda belum memiliki pemesanan.\nPesan perjalanan Anda berikutnya sekarang!',
                            style: TextStyle(fontSize: 16.sp),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomeScreen()),
                                );
                              },
                              child: Text('Pesan Sekarang'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD100),
                                foregroundColor: const Color(0xFF265AA5),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index];
                        final String asal = data['asal'];
                        final String tujuan = data['tujuan'];
                        final String kode = data['kode_pemesanan'];
                        final int total = data['total_pembayaran'] ?? 0;
                        final String metode = data['metode_pembayaran'] ?? 'COD';
                        final String status = data['status'] ?? 'Menunggu Konfirmasi';

                        // 🎨 Warna Status Dinamis
                        Color statusColor;
                        if (status.toLowerCase().contains('verifikasi')) {
                          statusColor = Colors.green;
                        } else if (status.toLowerCase().contains('gagal') || status.toLowerCase().contains('batal')) {
                          statusColor = Colors.amber[800]!;
                        } else {
                          statusColor = Colors.red;
                        }

                        return Card(
                          margin: EdgeInsets.only(bottom: 16.h),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$asal → $tujuan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: const Color(0xFF265AA5),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text("Kode Pemesanan: $kode", style: TextStyle(fontSize: 14.sp)),
                                Text("Metode Pembayaran: $metode", style: TextStyle(fontSize: 14.sp)),
                                Text(
                                  "Status: $status",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F6FA), // 🎨 Warna latar total
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    "Total: Rp$total",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF265AA5),
                                    ),
                                  ),
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

              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF265AA5),
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.confirmation_num),
                    label: 'Tiket',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
