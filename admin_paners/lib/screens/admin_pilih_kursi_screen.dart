import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Pastikan ini diimpor untuk NumberFormat
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Untuk debugPrint

// Import denah kursi - PASTIKAN KEDUA FILE INI SUDAH SESUAI DENGAN DEFINISI TERAKHIR YANG SAYA BERIKAN
import 'kursi/kursi_ac.dart';
import 'kursi/kursi_eko.dart';

// ✅ IMPORT HALAMAN BARU INI
import 'admin_isi_penumpang_screen.dart';


class AdminPilihKursiScreen extends StatefulWidget {
  final DocumentSnapshot busData;
  // Tanggal yang diformat dari PemesananManualScreen (contoh: "21 Jun 2025")
  // ASUMSI: Ini sudah dalam format "DD Mon BCE" (misal: "21 Jun 2025")
  final String tanggalPemesanan; 

  const AdminPilihKursiScreen({
    super.key,
    required this.busData,
    required this.tanggalPemesanan,
  });

  @override
  State<AdminPilihKursiScreen> createState() => _AdminPilihKursiScreenState();
}

class _AdminPilihKursiScreenState extends State<AdminPilihKursiScreen> {
  final Map<int, bool> kursiStatus = {};
  Set<int> selectedSeats = {};
  late int hargaTiketPerKursi;
  bool isLoading = true;

  late int totalSeatsBus;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF265AA5),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    hargaTiketPerKursi = widget.busData['biaya'] ?? 0;
    totalSeatsBus = widget.busData['jumlah_kursi'] as int? ?? 0;

    for (int i = 1; i <= totalSeatsBus; i++) {
      kursiStatus[i] = false;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchBookedSeats();
    });
  }

  Future<void> fetchBookedSeats() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final String asalBus = widget.busData['asal'] ?? '';
      final String tujuanBus = widget.busData['tujuan'] ?? '';
      final String jamBusUntukQuery = widget.busData['jam'] ?? ''; 
      final String kelasBus = widget.busData['kelas'] ?? '';
      final String tanggalBusUntukQuery = widget.tanggalPemesanan; 


      debugPrint('--- AdminPilihKursiScreen: Fetching Booked Seats Query ---');
      debugPrint('Querying collection: pemesanan');
      debugPrint('  where asal: "$asalBus"');
      debugPrint('  where tujuan: "$tujuanBus"');
      debugPrint('  where tanggal: "$tanggalBusUntukQuery" (Passed from PemesananManualScreen)');
      debugPrint('  where jam: "$jamBusUntukQuery"');
      debugPrint('  where kelas: "$kelasBus"');
      debugPrint('  where status in: ["Terverifikasi", "Menunggu Konfirmasi"]');


      final QuerySnapshot pemesananSnapshot = await FirebaseFirestore.instance
          .collection('pemesanan')
          .where('asal', isEqualTo: asalBus)
          .where('tujuan', isEqualTo: tujuanBus)
          .where('tanggal', isEqualTo: tanggalBusUntukQuery)
          .where('jam', isEqualTo: jamBusUntukQuery)
          .where('kelas', isEqualTo: kelasBus)
          .where('status', whereIn: ['Terverifikasi', 'Menunggu Konfirmasi'])
          .get();

      if (pemesananSnapshot.docs.isEmpty) {
        debugPrint('No bookings found for this criteria. All seats available.');
      } else {
        debugPrint('Found ${pemesananSnapshot.docs.length} relevant bookings.');
      }

      if (mounted) {
        setState(() {
          for (int i = 1; i <= totalSeatsBus; i++) {
            kursiStatus[i] = false;
          }
          selectedSeats.clear();

          for (var doc in pemesananSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final List<dynamic> bookedKursi = data['kursi'] ?? [];
            debugPrint('  Booked seats from doc ${doc.id} (status: ${data['status']}): $bookedKursi');
            for (var seat in bookedKursi) {
              int? parsedSeat;
              if (seat is int) {
                parsedSeat = seat;
              } else if (seat is String) {
                parsedSeat = int.tryParse(seat);
              }
              if (parsedSeat != null && parsedSeat > 0 && parsedSeat <= totalSeatsBus) {
                kursiStatus[parsedSeat] = true;
              }
            }
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching booked seats: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kursi terpesan: ${e.toString()}', style: GoogleFonts.poppins())),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onSeatTap(int seatNumber) {
    setState(() {
      if (kursiStatus[seatNumber] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kursi $seatNumber sudah terpesan!', style: GoogleFonts.poppins())),
        );
        return;
      }

      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        selectedSeats.add(seatNumber);
      }
    });
  }

  void _navigateToInformasiPenumpangManual() {
    if (selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih setidaknya satu kursi untuk melanjutkan.')),
      );
      return;
    }


    // ✅ AKTIFKAN KODE INI DAN PASTIKAN SEMUA PARAMETER TERISI
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminIsiPenumpangScreen(
          asal: widget.busData['asal'],
          tujuan: widget.busData['tujuan'],
          tanggal: widget.tanggalPemesanan, // Tanggal sudah diformat "DD Mon BCE"
          jam: widget.busData['jam'], // Menggunakan 'jam'
          kelas: widget.busData['kelas'],
          selectedSeats: selectedSeats.toList(), // Kirim sebagai List
          hargaTiketPerKursi: hargaTiketPerKursi,
          busData: widget.busData, // Teruskan seluruh busData
        ),
      ),
    );
  }

  Widget _colorLegendBox(Color color, Color borderColor, {double size = 20}) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busKelas = widget.busData['kelas'] ?? 'Eko';
    final int sisaKursiHitung = totalSeatsBus - kursiStatus.values.where((booked) => booked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Pilih Kursi (${widget.busData['asal'] ?? 'Bus'} - ${widget.busData['tujuan'] ?? ''})',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF265AA5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchBookedSeats,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rincian Perjalanan:',
                        style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Dari: ${widget.busData['asal'] ?? 'N/A'} | Tujuan: ${widget.busData['tujuan'] ?? 'N/A'}',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      Text(
                        'Tanggal: ${widget.tanggalPemesanan} | Jam: ${widget.busData['jam'] ?? 'N/A'}',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      Text(
                        'Kelas: $busKelas | Harga: Rp ${NumberFormat('#,###', 'id_ID').format(hargaTiketPerKursi)}',
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Sisa Kursi: $sisaKursiHitung',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: sisaKursiHitung > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Pilih Kursi:',
                        style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _colorLegendBox(Colors.grey.shade400, Colors.grey.shade600),
                          SizedBox(width: 8.w),
                          Text("Terpesan", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87)),
                          SizedBox(width: 20.w),
                          _colorLegendBox(Colors.orange.shade300, Colors.orange),
                          SizedBox(width: 8.w),
                          Text("Dipilih", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87)),
                          SizedBox(width: 20.w),
                          _colorLegendBox(
                            busKelas == 'AC' ? Colors.green.shade200 : Colors.lightBlue.shade100,
                            busKelas == 'AC' ? Colors.green.shade400 : Colors.lightBlue,
                          ),
                          SizedBox(width: 8.w),
                          Text("Tersedia", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87)),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: busKelas == 'AC'
                          ? KursiAc(
                                totalSeats: totalSeatsBus,
                                kursiStatus: kursiStatus,
                                selectedSeats: selectedSeats,
                                onSeatTap: _onSeatTap,
                              )
                          : KursiEko(
                                totalSeats: totalSeatsBus,
                                kursiStatus: kursiStatus,
                                selectedSeats: selectedSeats,
                                onSeatTap: _onSeatTap,
                              ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: selectedSeats.isEmpty
          ? null
          : Container(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h + MediaQuery.of(context).padding.bottom),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Harga:',
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Rp ${NumberFormat('#,###', 'id_ID').format(hargaTiketPerKursi * selectedSeats.length)}',
                          style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF265AA5)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kursi Dipilih:',
                          style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: Text(
                            selectedSeats.isEmpty ? 'Belum ada' : (selectedSeats.toList()..sort()).join(', '),
                            style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF265AA5)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: _navigateToInformasiPenumpangManual,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD100),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          elevation: 5,
                        ),
                        child: Text(
                          'Lanjutkan Pemesanan',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}