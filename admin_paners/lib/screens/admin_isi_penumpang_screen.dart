import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// DITAMBAHKAN: Import halaman tujuan setelah booking berhasil.
// Pastikan nama file dan nama class widget-nya sudah benar.
import 'admin_home_screen.dart'; 

class AdminIsiPenumpangScreen extends StatefulWidget {
  final String asal;
  final String tujuan;
  final String tanggal;
  final String jam;
  final String kelas;
  final List<int> selectedSeats;
  final int hargaTiketPerKursi;
  final DocumentSnapshot busData;

  const AdminIsiPenumpangScreen({
    super.key,
    required this.asal,
    required this.tujuan,
    required this.tanggal,
    required this.jam,
    required this.kelas,
    required this.selectedSeats,
    required this.hargaTiketPerKursi,
    required this.busData,
  });

  @override
  State<AdminIsiPenumpangScreen> createState() => _AdminIsiPenumpangScreenState();
}

class _AdminIsiPenumpangScreenState extends State<AdminIsiPenumpangScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  String metodePembayaran = 'COD';
  bool isLoading = false;

  late final NumberFormat _currencyFormatter;
  late final TextStyle _infoLabelStyle;
  late final TextStyle _infoValueStyle;
  late final TextStyle _sectionTitleStyle;

  @override
  void initState() {
    super.initState();
    _currencyFormatter = NumberFormat('#,###', 'id_ID');
    _infoLabelStyle = GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87);
    _infoValueStyle = GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87);
    _sectionTitleStyle = GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold);
  }

  @override
  void dispose() {
    namaController.dispose();
    teleponController.dispose();
    super.dispose();
  }

  String generateKodePemesanan() {
    // ... (kode tidak berubah)
    String inisialAsal = widget.asal.length >= 2 ? widget.asal.substring(0, 2).toUpperCase() : widget.asal.toUpperCase();
    String inisialTujuan = widget.tujuan.length >= 2 ? widget.tujuan.substring(0, 2).toUpperCase() : widget.tujuan.toUpperCase();
    String tgl = '';
    try {
      tgl = DateFormat('dd').format(DateFormat('dd MMM yyyy', 'id_ID').parse(widget.tanggal));
    } catch (e) {
      debugPrint('Warning: Could not parse widget.tanggal for kode pemesanan: ${widget.tanggal}');
      tgl = widget.tanggal.substring(0,2);
    }
    String jam = widget.jam.contains(":") ? widget.jam.split(":")[0].padLeft(2, '0') : widget.jam.padLeft(2, '0');
    String kursi = widget.selectedSeats.length.toString().padLeft(2, '0');
    String timestampHash = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    return "${inisialAsal}${inisialTujuan}${tgl}${jam}${kursi}${timestampHash}";
  }

  Future<void> _processManualBooking() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final kodePemesanan = generateKodePemesanan();
      final adminUser = FirebaseAuth.instance.currentUser;
      final bookingData = {
        'uid': adminUser?.uid ?? 'admin_manual',
        'booked_by': adminUser?.email ?? 'admin_unknown',
        'asal': widget.asal,
        'tujuan': widget.tujuan,
        'tanggal': widget.tanggal,
        'jam': widget.jam,
        'kelas': widget.kelas,
        'nama': namaController.text.trim(),
        'telepon': teleponController.text.trim(),
        'jumlah_kursi': widget.selectedSeats.length,
        'kursi': widget.selectedSeats.toList(),
        'total_pembayaran': widget.hargaTiketPerKursi * widget.selectedSeats.length,
        'kode_pemesanan': kodePemesanan,
        'metode_pembayaran': metodePembayaran,
        'status': metodePembayaran == 'COD' ? 'Menunggu Konfirmasi' : 'Terverifikasi',
        'dipesan_pada': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('pemesanan').add(bookingData);

      // DIPERBARUI: Logika setelah sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pemesanan berhasil! Kode: $kodePemesanan'), backgroundColor: Colors.green));
        
        // Navigasi ke halaman home admin dan hapus semua halaman sebelumnya
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminHomeScreen()), // Ganti dengan nama class widget Anda
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      // Pengecekan `mounted` di sini penting, karena jika navigasi berhasil,
      // widget ini sudah di-dispose dan setState tidak boleh dipanggil.
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(
          'Detail Pemesanan Manual',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF265AA5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RincianPerjalananSection(
                  asal: widget.asal,
                  tujuan: widget.tujuan,
                  tanggal: widget.tanggal,
                  jam: widget.jam,
                  kelas: widget.kelas,
                  selectedSeats: widget.selectedSeats,
                  hargaTiketPerKursi: widget.hargaTiketPerKursi,
                  currencyFormatter: _currencyFormatter,
                  infoLabelStyle: _infoLabelStyle,
                  infoValueStyle: _infoValueStyle,
                  sectionTitleStyle: _sectionTitleStyle,
                ),
                const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                SizedBox(height: 16.h),
                _DetailPenumpangSection(
                  namaController: namaController,
                  teleponController: teleponController,
                  sectionTitleStyle: _sectionTitleStyle,
                ),
                SizedBox(height: 16.h),
                _MetodePembayaranSection(
                  sectionTitleStyle: _sectionTitleStyle,
                  groupValue: metodePembayaran,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        metodePembayaran = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _TotalPembayaranSection(
        totalPembayaran: widget.hargaTiketPerKursi * widget.selectedSeats.length,
        isLoading: isLoading,
        onProcessBooking: _processManualBooking,
        currencyFormatter: _currencyFormatter,
      ),
    );
  }
}

// --- WIDGET-WIDGET KECIL DI BAWAH INI TIDAK BERUBAH ---

class _RincianPerjalananSection extends StatelessWidget {
  final String asal, tujuan, tanggal, jam, kelas;
  final List<int> selectedSeats;
  final int hargaTiketPerKursi;
  final NumberFormat currencyFormatter;
  final TextStyle infoLabelStyle, infoValueStyle, sectionTitleStyle;

  const _RincianPerjalananSection({
    required this.asal, required this.tujuan, required this.tanggal,
    required this.jam, required this.kelas, required this.selectedSeats,
    required this.hargaTiketPerKursi, required this.currencyFormatter,
    required this.infoLabelStyle, required this.infoValueStyle,
    required this.sectionTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Rincian Perjalanan", style: sectionTitleStyle),
        SizedBox(height: 12.h),
        _buildInfoRow('Asal', asal),
        _buildInfoRow('Tujuan', tujuan),
        _buildInfoRow('Tanggal', tanggal),
        _buildInfoRow('Jam', jam),
        _buildInfoRow('Kelas', kelas),
        _buildInfoRow('Kursi Dipilih', selectedSeats.join(', ')),
        _buildInfoRow('Harga per Kursi', 'Rp ${currencyFormatter.format(hargaTiketPerKursi)}'),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: infoLabelStyle)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(':', style: infoLabelStyle),
          ),
          Expanded(flex: 3, child: Text(value, style: infoValueStyle)),
        ],
      ),
    );
  }
}

class _DetailPenumpangSection extends StatelessWidget {
  final TextEditingController namaController;
  final TextEditingController teleponController;
  final TextStyle sectionTitleStyle;

  const _DetailPenumpangSection({
    required this.namaController,
    required this.teleponController,
    required this.sectionTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Detail Penumpang", style: sectionTitleStyle),
        SizedBox(height: 12.h),
        _buildTextField(
          controller: namaController,
          labelText: 'Nama Penumpang',
          prefixIcon: Icons.person_outline,
          keyboardType: TextInputType.name,
        ),
        
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) => (value == null || value.isEmpty) ? '$labelText wajib diisi' : null,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 15.sp),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF265AA5)) : null,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF265AA5), width: 1.5)),
      ),
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15.sp),
    );
  }
}

class _MetodePembayaranSection extends StatelessWidget {
  final TextStyle sectionTitleStyle;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _MetodePembayaranSection({
    required this.sectionTitleStyle,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Metode Pembayaran", style: sectionTitleStyle),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: Text('Cash on Delivery (COD)', style: GoogleFonts.poppins(fontSize: 15.sp)),
                value: 'COD',
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF265AA5),
              ),
              RadioListTile<String>(
                title: Text('Transfer Bank', style: GoogleFonts.poppins(fontSize: 15.sp)),
                value: 'Transfer',
                groupValue: groupValue,
                onChanged: onChanged,
                activeColor: const Color(0xFF265AA5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalPembayaranSection extends StatelessWidget {
  final int totalPembayaran;
  final bool isLoading;
  final VoidCallback onProcessBooking;
  final NumberFormat currencyFormatter;

  const _TotalPembayaranSection({
    required this.totalPembayaran,
    required this.isLoading,
    required this.onProcessBooking,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h + MediaQuery.of(context).viewPadding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 10, offset: Offset(0, -5))],
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran:', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              Text(
                'Rp ${currencyFormatter.format(totalPembayaran)}',
                style: GoogleFonts.poppins(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF265AA5)),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onProcessBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD100),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 2,
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Text(
                      'Verifikasi Pemesanan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18.sp),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}