import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kelola_bus.dart';
import 'package:intl/intl.dart';
class DetailBusScreen extends StatefulWidget {
  final String busId;
  final Map<String, dynamic> busData;

  DetailBusScreen({required this.busId, required this.busData});

  @override
  _DetailBusScreenState createState() => _DetailBusScreenState();
}

class _DetailBusScreenState extends State<DetailBusScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tanggalController;
  late TextEditingController _jamController;
  late TextEditingController _biayaController;
  String? _kelas;
  String? _asal;
  String? _tujuan;
  bool _isUpdated = false;

  final List<String> kotaList = [
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

  @override
  void initState() {
    super.initState();
    _asal = widget.busData['asal'];
    _tujuan = widget.busData['tujuan'];
    _kelas = widget.busData['kelas'];
    final tanggalData = widget.busData['tanggal'];
   final firstTanggal = (tanggalData is List && tanggalData.isNotEmpty)
    ? tanggalData.first
    : '';
      final reformattedTanggal = firstTanggal.isNotEmpty
          ? DateFormat('dd MMM yyyy').parse(firstTanggal)
          : null;

      _tanggalController = TextEditingController(
        text: reformattedTanggal != null
            ? DateFormat('dd-MM-yyyy').format(reformattedTanggal)
            : '',
      );

    _jamController = TextEditingController(text: widget.busData['jam']);
    _biayaController = TextEditingController(
      text: widget.busData['biaya'].toString(),
    );
  }

  void _updateBus() async {
    if (_formKey.currentState!.validate()) {
      DateTime startDate = DateFormat('dd-MM-yyyy').parse(_tanggalController.text);
      List<String> tanggalList = List.generate(7, (i) {
        return DateFormat('dd MMM yyyy').format(startDate.add(Duration(days: i)));
      });
      await FirebaseFirestore.instance
          .collection('buses')
          .doc(widget.busId)
          .update({
            'asal': _asal,
            'tujuan': _tujuan,
            'kelas': _kelas,
            'tanggal': tanggalList,
            'jam': _jamController.text,
            'biaya': int.parse(_biayaController.text),
          });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KelolaBusScreen()),
      );
    }
  }

  void _deleteBus() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Konfirmasi Hapus Bus"),
            content: Text("Apakah Anda yakin ingin menghapus data bus ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('buses')
          .doc(widget.busId)
          .delete();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KelolaBusScreen()),
      );
    }
  }

  void _checkIfUpdated() {
    final initial = widget.busData;
    if (_asal != initial['asal'] ||
        _tujuan != initial['tujuan'] ||
        _kelas != initial['kelas'] ||
        _tanggalController.text != initial['tanggal'] ||
        _jamController.text != initial['jam'] ||
        _biayaController.text != initial['biaya'].toString()) {
      setState(() => _isUpdated = true);
    } else {
      setState(() => _isUpdated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ⬅️ penting
      backgroundColor: Color(0xFF0D4695),
      body: SafeArea(
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          builder:
              (_, child) => SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom +
                      20, // ⬅️ adaptif saat keyboard muncul
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    SizedBox(height: 12.h),
                    Image.asset(
                      'assets/images/identitas_logo.png',
                      height: 80.h,
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(20.w),
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Form(
                        key: _formKey,
                        onChanged: _checkIfUpdated,
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
                            SizedBox(height: 12.h),
                            DropdownButtonFormField<String>(
                              value: _asal,
                              decoration: _inputDecoration("Asal"),
                              items:
                                  ['Medan']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() => _asal = val);
                                _checkIfUpdated();
                              },
                            ),
                            SizedBox(height: 12.h),
                            DropdownButtonFormField<String>(
                              value: _tujuan,
                              decoration: _inputDecoration("Tujuan"),
                              items:
                                  kotaList
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() => _tujuan = val);
                                _checkIfUpdated();
                              },
                            ),
                            SizedBox(height: 12.h),
                            DropdownButtonFormField<String>(
                              value: _kelas,
                              decoration: _inputDecoration("Kelas"),
                              items:
                                  ['AC', 'Ekonomi']
                                      .map(
                                        (e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() => _kelas = val);
                                _checkIfUpdated();
                              },
                            ),
                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _tanggalController,
                              readOnly: true,
                              decoration: _inputDecoration(
                                "Tanggal Keberangkatan",
                              ),
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    Duration(days: 365),
                                  ),
                                  lastDate: DateTime.now().add(
                                    Duration(days: 365),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _tanggalController.text =
                                        "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
                                    _checkIfUpdated();
                                  });
                                }
                              },
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Wajib diisi'
                                          : null,
                            ),

                            SizedBox(height: 12.h),
                            TextFormField(
                              controller: _jamController,
                              readOnly: true,
                              decoration: _inputDecoration("Jam Keberangkatan"),
                              onTap: () async {
                                TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  final now = DateTime.now();
                                  final dt = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    picked.hour,
                                    picked.minute,
                                  );
                                  final formatted =
                                      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                  setState(() {
                                    _jamController.text = formatted;
                                    _checkIfUpdated();
                                  });
                                }
                              },
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Wajib diisi'
                                          : null,
                            ),

                            SizedBox(height: 12.h),
                            _buildTextField(
                              _biayaController,
                              "Biaya",
                              isNumber: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isUpdated)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 10.h,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateBus,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFD100),
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Perbarui Data Bus",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 10.h,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _deleteBus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            "Hapus Bus",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    labelStyle: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[700]),
  );

  TextFormField _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: _inputDecoration(hint),
    validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
  );
}
