import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'pilih_kursi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PilihBusScreen extends StatelessWidget {
  final String asal;
  final String tujuan;
  final String tanggal;

  const PilihBusScreen({
    Key? key,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
  }) : super(key: key);

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
          (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: const Color(0xFFF5F6FA),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black),
                title: const Text(
                  'Pilih Bus',
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: false,
                systemOverlayStyle: SystemUiOverlayStyle.dark,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF265AA5),
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/identitas_logo.png',
                                      height: 60.sp,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: 10.h),
                                    Text(
                                      "$asal → $tujuan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.white),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        tanggal,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        FutureBuilder<QuerySnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('buses')
                                  .where('asal', isEqualTo: asal)
                                  .where('tujuan', isEqualTo: tujuan)
                                  .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40.0),
                                  child: Text(
                                    "Tidak ada jadwal bus, silahkan menunggu informasi selanjutnya",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            final busDocs =
                                snapshot.data!.docs.where((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final List<dynamic> tanggalList =
                                      data['tanggal'] ?? [];
                                  return tanggalList.contains(tanggal);
                                }).toList();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: busDocs.length,
                              itemBuilder: (context, index) {
                                final bus =
                                    busDocs[index].data()
                                        as Map<String, dynamic>;
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16.h),
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4.r,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            bus['kelas'] ?? 'Kelas',
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF265AA5),
                                            ),
                                          ),
                                          Text(
                                            "Rp ${bus['biaya'].toString()}",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      SizedBox(height: 8.h),
                                      FutureBuilder<QuerySnapshot>(
                                        future:
                                            FirebaseFirestore.instance
                                                .collection('pemesanan')
                                                .where('asal', isEqualTo: asal)
                                                .where(
                                                  'tujuan',
                                                  isEqualTo: tujuan,
                                                )
                                                .where(
                                                  'tanggal',
                                                  isEqualTo: tanggal,
                                                )
                                                .where(
                                                  'jam',
                                                  isEqualTo: bus['jam'],
                                                )
                                                .get(),
                                        builder: (context, snapshot) {
                                          int kursiTerpesan = 0;
                                          if (snapshot.hasData) {
                                            for (var doc
                                                in snapshot.data!.docs) {
                                              final data =
                                                  doc.data()
                                                      as Map<String, dynamic>;
                                              final kursi = data['kursi'] ?? [];
                                              kursiTerpesan +=
                                                  (kursi as List).length;
                                            }
                                          }
                                          final int totalKursi =
                                              bus['jumlah_kursi'] ?? 0;
                                          final int sisaKursi =
                                              totalKursi - kursiTerpesan;

                                          return Text(
                                            "$sisaKursi kursi tersedia",
                                            style: TextStyle(fontSize: 12.sp),
                                          );
                                        },
                                      ),
                                      SizedBox(height: 8.h),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            bus['jam'] ?? '-',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                          Text(
                                            "Nomor Bus: ${bus['nomor_bus'] ?? '-'}",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final busDataWithTanggal =
                                                Map<String, dynamic>.from(bus);
                                            busDataWithTanggal['tanggal'] =
                                                tanggal; // ⬅️ tambahkan tanggal terpilih

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => PilihKursiScreen(
                                                      busData:
                                                          busDataWithTanggal,
                                                    ),
                                              ),
                                            );
                                          },

                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFD100),
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                          ),
                                          child: Text(
                                            "Pilih Kursi",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
