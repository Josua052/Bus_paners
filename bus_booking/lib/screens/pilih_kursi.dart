import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'informasi_penumpang.dart';
import 'kursi/kursi_ac.dart';
import 'kursi/kursi_eko.dart';

class PilihKursiScreen extends StatefulWidget {
  final Map<String, dynamic> busData;

  const PilihKursiScreen({Key? key, required this.busData}) : super(key: key);

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen> {
  final Map<int, bool> kursiStatus = {};
  Set<int> selectedSeats = {};
  late int hargaTiket;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    hargaTiket = widget.busData['biaya'] ?? 0;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    fetchBookedSeats();
  }

  Future<void> fetchBookedSeats() async {
    final nomorBus = widget.busData['nomor_bus'];
    final tanggal = widget.busData['tanggal'];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('pemesanan')
            .where('nomor_bus', isEqualTo: nomorBus)
            .where('tanggal', isEqualTo: tanggal)
            .get();

    final booked = <int>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['kursi'] != null && data['kursi'] is List) {
        for (var seat in data['kursi']) {
          booked.add(int.parse(seat.toString()));
        }
      }
    }

    setState(() {
      for (int i = 1; i <= 45; i++) {
        kursiStatus[i] = booked.contains(i);
      }
      isLoading = false;
    });
  }

  @override
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
    child: AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          title: const Text("Pilih Kursi"),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    Text(
                      "${widget.busData['asal']} → ${widget.busData['tujuan']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.busData['tanggal'] ?? '-',
                      style: TextStyle(fontSize: 15.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.busData['jam'] ?? '-',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.busData['kelas'] ?? '-',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: Colors.blue.shade900,
                          width: 2.w,
                        ),
                        color: Colors.white,
                      ),
                      child: widget.busData['kelas'] == 'AC'
                          ? KursiAC(
                              kursiStatus: kursiStatus,
                              selectedSeats: selectedSeats,
                              onSeatTap: onSeatTap,
                            )
                          : KursiEko(
                              kursiStatus: kursiStatus,
                              selectedSeats: selectedSeats,
                              onSeatTap: onSeatTap,
                            ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _colorLegendBox(Colors.grey.shade400),
                        SizedBox(width: 8.w),
                        Text(" : Tersedia", style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 20.w),
                        _colorLegendBox(const Color(0xFFFFD10A)),
                        SizedBox(width: 8.w),
                        Text(" : Sudah dipesan", style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                    SizedBox(height: 100.h),
                  ],
                ),
              ),
        bottomNavigationBar: selectedSeats.isEmpty
            ? null
            : Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  12.h,
                  24.w,
                  16.h + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rp harga tiket",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "Rp ${(hargaTiket * selectedSeats.length)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Kursi ke",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              (() {
                                final sorted = selectedSeats.toList();
                                sorted.sort();
                                return sorted.join(", ");
                              })(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InformasiPenumpangScreen(
                                dari: widget.busData['asal'],
                                tujuan: widget.busData['tujuan'],
                                waktu:
                                    "${widget.busData['tanggal']} ${widget.busData['jam']}",
                                selectedSeats: selectedSeats,
                                hargaTiketPerKursi: hargaTiket,
                                kelas: widget.busData['kelas'], // Dikirim ke screen berikutnya
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        child: Text(
                          "Lanjutkan",
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
    ),
  );
}


  void onSeatTap(int seatNumber) {
    setState(() {
      if (kursiStatus[seatNumber] == true) return;
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else if (selectedSeats.length < 4) {
        selectedSeats.add(seatNumber);
      } else {
        showDialog(
          context: context,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/penumpang_duduk.png',
                        width: 400.w,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        "Jumlah kursi yang hanya dapat dipilih adalah 4",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFD10A),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: const Text(
                            "OK",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );
      }
    });
  }

  Widget _colorLegendBox(Color color) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}
