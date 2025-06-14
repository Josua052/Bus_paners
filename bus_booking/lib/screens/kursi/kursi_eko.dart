import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KursiEko extends StatelessWidget {
  final Map<int, bool> kursiStatus;
  final Set<int> selectedSeats;
  final void Function(int) onSeatTap;

  const KursiEko({
    Key? key,
    required this.kursiStatus,
    required this.selectedSeats,
    required this.onSeatTap,
  }) : super(key: key);

  Widget _buildSeat(int number) {
    bool isBooked = kursiStatus[number] ?? false;
    bool isSelected = selectedSeats.contains(number);

    Color color = isBooked
        ? const Color(0xFFFFD10A)
        : isSelected
            ? Colors.green
            : Colors.grey.shade400;

    return GestureDetector(
      onTap: isBooked
          ? null
          : () {
              onSeatTap(number);
            },
      child: Container(
        width: 40.w,
        height: 40.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          number.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
      ),
    );
  }

  Widget _emptySpace() => SizedBox(width: 40.w);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pintu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            Image.asset('assets/images/setir_mobil.png', width: 40.w, height: 40.w),
          ],
        ),
        SizedBox(height: 12.h),
        ...List.generate(7, (i) {
          int base = i * 4 + 1;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [_buildSeat(base), SizedBox(width: 12.w), _buildSeat(base + 1)]),
                _emptySpace(),
                Row(children: [_buildSeat(base + 2), SizedBox(width: 12.w), _buildSeat(base + 3)]),
              ],
            ),
          );
        }),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Pintu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
            Row(children: [
              _buildSeat(29),
              SizedBox(width: 12.w),
              _buildSeat(30),
            ]),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSeat(31),
            _buildSeat(32),
            _buildSeat(33),
            _buildSeat(34),
            _buildSeat(35),
          ],
        )
      ],
    );
  }
}
