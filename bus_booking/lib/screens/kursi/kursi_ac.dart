import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KursiAC extends StatelessWidget {
  final Map<int, bool> kursiStatus;
  final Set<int> selectedSeats;
  final Function(int) onSeatTap;

  const KursiAC({
    Key? key,
    required this.kursiStatus,
    required this.selectedSeats,
    required this.onSeatTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Baris atas: setir & pintu
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pintu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            Image.asset(
              'assets/images/setir_mobil.png',
              width: 40.w,
              height: 40.w,
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Barisan kursi 1–32
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
                  SizedBox(width: 40.w),
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

        // Tambahan baris Pintu (kiri) dan kursi 33-34 (kanan)
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pintu", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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

        // Barisan kursi 35–42
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
                  SizedBox(width: 40.w),
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

        // Baris Toilet dan kursi 43–45
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 60.w,
              height: 40.w,
              color: Colors.yellow.shade700,
              alignment: Alignment.center,
              child: Text("Toilet", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ],
    );
  }

  Widget _buildSeat(int seatNumber) {
    bool isBooked = kursiStatus[seatNumber] ?? false;
    bool isSelected = selectedSeats.contains(seatNumber);

    Color bgColor = isBooked
        ? const Color(0xFFFFD10A)
        : isSelected
            ? Colors.green
            : Colors.grey.shade400;

    return GestureDetector(
      onTap: isBooked ? null : () => onSeatTap(seatNumber),
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNumber.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
      ),
    );
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
