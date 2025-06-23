import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class KursiEko extends StatefulWidget {
  final int totalSeats;
  final Map<int, bool> kursiStatus; // Status terpesan dari DB (true = terpesan)
  final Set<int> selectedSeats; // Kursi yang sedang dipilih oleh user/admin di layar ini
  final Function(int seatNumber) onSeatTap; // Callback saat kursi ditekan

  const KursiEko({
    super.key,
    required this.totalSeats,
    required this.kursiStatus,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  State<KursiEko> createState() => _KursiEkoState();
}

class _KursiEkoState extends State<KursiEko> {
  Widget _buildSeat(int seatNumber) {
    // Jika nomor kursi melebihi totalSeats yang diizinkan untuk bus ini, tampilkan ruang kosong.
    // Ini penting agar layout tidak error jika bus memiliki jumlah kursi kurang dari 35.
    if (seatNumber > widget.totalSeats) {
      return SizedBox(
        width: 40.w,
        height: 40.w,
      );
    }
    // Jika nomor kursi kurang dari 1, ini juga tidak valid
    if (seatNumber < 1) {
      return SizedBox(
        width: 40.w,
        height: 40.w,
      );
    }


    bool isBooked = widget.kursiStatus[seatNumber] == true; // Cek status terpesan dari Map yang diterima
    bool isSelected = widget.selectedSeats.contains(seatNumber); // Cek status dipilih dari Set yang diterima

    // DEBUGGING: Output status setiap kursi ke konsol
    // Ini adalah kunci untuk memahami masalah. Pastikan output ini muncul dan sesuai harapan.
    debugPrint('Kursi Eko $seatNumber: isBooked=$isBooked, isSelected=$isSelected');


    // Menyesuaikan warna background kursi untuk Ekonomi
    Color bgColor = isBooked
        ? Colors.grey.shade400 // Kursi terpesan (abu-abu)
        : isSelected
            ? Colors.orange.shade300 // Kursi dipilih (oranye)
            : Colors.lightBlue.shade100; // Kursi tersedia (biru muda)

    // Menyesuaikan warna border kursi (stroke) untuk Ekonomi
    Color borderColor = isBooked
        ? Colors.grey.shade600
        : isSelected
            ? Colors.orange
            : Colors.lightBlue; // Warna border untuk Eko tersedia

    return GestureDetector(
      onTap: isBooked ? null : () => widget.onSeatTap(seatNumber), // onSeatTap diteruskan ke parent
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNumber.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: isBooked ? Colors.white : (isSelected ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _emptySpace() => SizedBox(width: 40.w); // Gang tengah

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris paling atas: Pintu & Setir
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pintu Depan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Image.asset('assets/images/setir_mobil.png', width: 40.w, height: 40.w),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Barisan kursi 1-28 (7 baris x 4 kursi)
          Column(
            children: List.generate(7, (i) {
              int base = i * 4 + 1;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      _buildSeat(base),
                      SizedBox(width: 12.w),
                      _buildSeat(base + 1),
                    ]),
                    _emptySpace(),
                    Row(children: [
                      _buildSeat(base + 2),
                      SizedBox(width: 12.w),
                      _buildSeat(base + 3),
                    ]),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),

          // Barisan kursi 29-30 (dekat pintu)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pintu Tengah", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Row(children: [
                  _buildSeat(29),
                  SizedBox(width: 12.w),
                  _buildSeat(30),
                ]),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Barisan kursi 31-35 (baris paling belakang, 5 kursi)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSeat(31),
                _buildSeat(32),
                _buildSeat(33),
                _buildSeat(34),
                _buildSeat(35),
              ],
            ),
          ),
        ],
      ),
    );
  }
}