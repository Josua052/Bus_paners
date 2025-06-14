import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'kelola_bus.dart';

class TambahBusScreen extends StatefulWidget {
  @override
  State<TambahBusScreen> createState() => _TambahBusScreenState();
}

class _TambahBusScreenState extends State<TambahBusScreen> {
  final List<String> kotaList = [
    'Medan',
    'Tebing Tinggi',
    'Kisaran',
    'Rantau Parapat',
    'Kota Pinang',
    'Langga Payung',
    'Gunung Tua',
    'Binangan',
    'Sibuhuan',
    'Sosa Ujung Batu',
    'Mananti',
    'Dalu dalu',
    'Pasir Pangaraian',
    'Padang Sidempuan',
    'Batang Toru',
  ];

  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController jamController = TextEditingController();
  final TextEditingController biayaController = TextEditingController();

  String? selectedAsal = 'Medan';
  String? selectedTujuan;
  String? selectedKelas;
  int jumlahKursi = 0;

  void _simpanBus() async {
    if (selectedAsal == null ||
        selectedTujuan == null ||
        selectedKelas == null ||
        tanggalController.text.isEmpty ||
        jamController.text.isEmpty ||
        biayaController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Semua kolom wajib diisi")));
      return;
    }
    // Konversi input string ke DateTime
    DateTime startDate = DateFormat(
      'dd MMM yyyy',
    ).parse(tanggalController.text);

    // Generate 7 tanggal ke depan
    List<String> tanggalList = List.generate(7, (i) {
      return DateFormat('dd MMM yyyy').format(startDate.add(Duration(days: i)));
    });

    await FirebaseFirestore.instance.collection('buses').add({
      'asal': selectedAsal,
      'tujuan': selectedTujuan,
      'kelas': selectedKelas,
      'jumlah_kursi': jumlahKursi,
      'tanggal': tanggalList,
      'jam': jamController.text,
      'biaya': int.parse(biayaController.text),
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Bus berhasil disimpan!")));

    Navigator.pop(context);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        tanggalController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        jamController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D4695),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 16.h),
            Text(
              "List Bus",
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Image.asset('assets/images/identitas_logo.png', height: 120.h),
            SizedBox(height: 20.h),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20.w),
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Detail Bus",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      DropdownButtonFormField<String>(
                        value: selectedAsal,
                        decoration: _dropdownDecoration("Asal"),
                        items:
                            ['Medan']
                                .map(
                                  (kota) => DropdownMenuItem(
                                    value: kota,
                                    child: Text(kota),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedAsal = value),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: selectedTujuan,
                        decoration: _dropdownDecoration("Tujuan"),
                        items:
                            kotaList
                                .where(
                                  (kota) => kota != 'Medan',
                                ) // Filter agar Medan tidak muncul
                                .map(
                                  (kota) => DropdownMenuItem(
                                    value: kota,
                                    child: Text(kota),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => selectedTujuan = value),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<String>(
                        value: selectedKelas,
                        decoration: _dropdownDecoration("Kelas"),
                        items:
                            ['AC', 'Ekonomi']
                                .map(
                                  (kelas) => DropdownMenuItem(
                                    value: kelas,
                                    child: Text(kelas),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedKelas = value;
                            jumlahKursi = (value == 'AC') ? 45 : 35;
                          });
                        },
                      ),
                      SizedBox(height: 12.h),
                      _inputField(
                        controller: tanggalController,
                        hint: "Tanggal Keberangkatan",
                        readOnly: true,
                        onTap: _selectDate,
                      ),
                      SizedBox(height: 12.h),
                      _inputField(
                        controller: jamController,
                        hint: "Jam Keberangkatan",
                        readOnly: true,
                        onTap: _selectTime,
                      ),
                      SizedBox(height: 12.h),
                      _inputField(
                        controller: biayaController,
                        hint: "Biaya Tiket",
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedAsal == null ||
                        selectedTujuan == null ||
                        selectedKelas == null ||
                        tanggalController.text.isEmpty ||
                        jamController.text.isEmpty ||
                        biayaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Semua kolom wajib diisi")),
                      );
                      return;
                    }

                    try {
                      DateTime startDate = DateFormat('dd MMM yyyy').parse(tanggalController.text);
                        List<String> tanggalList = List.generate(7, (i) {
                          return DateFormat('dd MMM yyyy').format(startDate.add(Duration(days: i)));
                        });
                      await FirebaseFirestore.instance.collection('buses').add({
                        'asal': selectedAsal,
                        'tujuan': selectedTujuan,
                        'kelas': selectedKelas,
                        'jumlah_kursi': jumlahKursi,
                        'tanggal': tanggalList,
                        'jam': jamController.text,
                        'biaya': int.parse(biayaController.text),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Bus berhasil disimpan!")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KelolaBusScreen(),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal menyimpan data: $e")),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD100),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    "Simpan Bus",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}
