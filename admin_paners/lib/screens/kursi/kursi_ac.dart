import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KursiAc extends StatefulWidget {
  final int totalSeats;
  final Map<int, bool> kursiStatus; // Status terpesan dari DB (true = terpesan)
  final Set<int> selectedSeats; // Kursi yang sedang dipilih oleh user/admin di layar ini
  final Function(int seatNumber) onSeatTap; // Callback saat kursi ditekan

  const KursiAc({
    super.key,
    required this.totalSeats,
    required this.kursiStatus,
    required this.selectedSeats,
    required this.onSeatTap,
  });

  @override
  State<KursiAc> createState() => _KursiAcState();
}

class _KursiAcState extends State<KursiAc> {
  Widget _buildSeat(int seatNumber) {
    // Pastikan nomor kursi ini valid (tidak melebihi totalSeats)
    if (seatNumber < 1 || seatNumber > widget.totalSeats) {
      return SizedBox(
        width: 40.w,
        height: 40.w,
        // Optional: return an empty container or smaller SizedBox for missing seats if not all 45 exist
      );
    }

    bool isBooked = widget.kursiStatus[seatNumber] == true;
    bool isSelected = widget.selectedSeats.contains(seatNumber);

    Color bgColor = isBooked
        ? Colors.green.shade400
        : isSelected
            ? Colors.orange.shade300
            : Colors.grey.shade200;

    Color borderColor = isBooked
        ? Colors.green.shade600
        : isSelected
            ? Colors.orange
            : Colors.grey.shade400;

    return GestureDetector(
      onTap: isBooked ? null : () => widget.onSeatTap(seatNumber),
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

  @override
  Widget build(BuildContext context) {
    return Container( // --- DITAMBAHKAN: Container Pembungkus (Kerangka Bus) ---
      padding: EdgeInsets.all(20.w), // Padding internal di dalam kerangka bus
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Warna latar belakang di dalam kerangka
        borderRadius: BorderRadius.circular(24.r), // Sudut membulat untuk kerangka
        border: Border.all(color: Colors.grey.shade300, width: 2), // Garis pembungkus (stroke)
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
          // Baris atas: setir & pintu depan
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pintu Depan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                Image.asset(
                  'assets/images/setir_mobil.png',
                  width: 40.w,
                  height: 40.w,
                ),
              ],
            ),
          ),
          // Barisan kursi 1–32 (8 baris x 4 kursi)
          Column(
            children: List.generate(8, (row) {
              int base = row * 4;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildSeat(base + 1),
                        SizedBox(width: 12.w),
                        _buildSeat(base + 2),
                      ],
                    ),
                    SizedBox(width: 40.w), // Gang tengah
                    Row(
                      children: [
                        _buildSeat(base + 3),
                        SizedBox(width: 12.w),
                        _buildSeat(base + 4),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          // Tambahan baris Pintu Tengah (kiri) dan kursi 33-34 (kanan)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pintu Tengah", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    _buildSeat(33),
                    SizedBox(width: 12.w),
                    _buildSeat(34),
                  ],
                ),
              ],
            ),
          ),

          // Barisan kursi 35–42 (2 baris x 4 kursi)
          Column(
            children: List.generate(2, (i) {
              int base = 35 + i * 4;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildSeat(base),
                        SizedBox(width: 12.w),
                        _buildSeat(base + 1),
                      ],
                    ),
                    SizedBox(width: 40.w), // Gang tengah
                    Row(
                      children: [
                        _buildSeat(base + 2),
                        SizedBox(width: 12.w),
                        _buildSeat(base + 3),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),

          // Baris Toilet dan kursi 43–45 (belakang)
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 60.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: Text("Toilet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87)),
                ),
                _buildSeat(43),
                Row(
                  children: [
                    _buildSeat(44),
                    SizedBox(width: 12.w),
                    _buildSeat(45),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ); // --- END Container Pembungkus ---
  }
}