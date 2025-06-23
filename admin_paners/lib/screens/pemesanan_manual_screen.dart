import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Pastikan ini diimpor
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_pilih_kursi_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_home_screen.dart';
import 'kelola_bus.dart';
import 'kelola_penumpang.dart';
import 'login_screen.dart';
class PemesananManualScreen extends StatefulWidget {
  const PemesananManualScreen({super.key});

  @override
  State<PemesananManualScreen> createState() => _PemesananManualScreenState();
}

class _PemesananManualScreenState extends State<PemesananManualScreen> {
  final String fixedFromCity = 'Medan';
  String? selectedTo;
  DateTime? selectedDate;

  List<String> kotaTujuan = [];
  bool isLoadingKota = true;
  bool isSearchingBus = false;
  List<DocumentSnapshot>? foundBuses;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    fetchKotaTujuanFromFirebase();
  }

  Future<void> fetchKotaTujuanFromFirebase() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('buses').get();
      final Set<String> tujuanSet = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('asal') && data['asal'] == fixedFromCity) {
          if (data.containsKey('tujuan')) {
            tujuanSet.add(data['tujuan']);
          }
        }
      }

      setState(() {
        kotaTujuan = tujuanSet.toList();
        kotaTujuan.sort();
        isLoadingKota = false;
      });
    } catch (e) {
      print("Error fetching destination cities: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat daftar kota tujuan: ${e.toString()}'),
          ),
        );
        setState(() {
          isLoadingKota = false;
        });
      }
    }
  }

  void _showKotaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 20.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
            ),
            child: StatefulBuilder(
              builder: (context, setStateModal) {
                final List<String> filteredKotaTujuan =
                    kotaTujuan
                        .where(
                          (city) => city.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          ),
                        )
                        .toList();

                return Column(
                  children: [
                    TextField(
                      controller: searchController,
                      onChanged: (_) => setStateModal(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari kota tujuan...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        suffixIcon:
                            searchController.text.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchController.clear();
                                    setStateModal(() {});
                                  },
                                )
                                : null,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    isLoadingKota
                        ? const Center(child: CircularProgressIndicator())
                        : filteredKotaTujuan.isEmpty
                        ? const Center(
                          child: Text('Tidak ada kota tujuan tersedia.'),
                        )
                        : Expanded(
                          child: ListView.builder(
                            itemCount: filteredKotaTujuan.length,
                            itemBuilder: (context, index) {
                              final city = filteredKotaTujuan[index];
                              return ListTile(
                                title: Text(city, style: GoogleFonts.poppins()),
                                onTap: () {
                                  setState(() {
                                    selectedTo = city;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF265AA5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF265AA5),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _searchBuses() async {
    if (selectedTo == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi kota tujuan dan tanggal perjalanan.'),
        ),
      );
      return;
    }

    setState(() {
      isSearchingBus = true;
      foundBuses = null;
    });

    try {
      // ✅ KOREKSI: Gunakan format tanggal "DD Mon BCE" untuk query dan untuk dikirim
      final formattedDateForQuery = DateFormat(
        'dd MMM yyyy',
      ).format(selectedDate!);

      final QuerySnapshot busSnapshot =
          await FirebaseFirestore.instance
              .collection('buses')
              .where('asal', isEqualTo: fixedFromCity)
              .where('tujuan', isEqualTo: selectedTo!)
              .get();

      final List<DocumentSnapshot> availableBuses = [];
      for (var doc in busSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final List<dynamic> tanggalList = data['tanggal'] ?? [];
        if (tanggalList.contains(formattedDateForQuery)) {
          availableBuses.add(doc);
        }
      }

      setState(() {
        foundBuses = availableBuses;
        isSearchingBus = false;
      });

      if (foundBuses!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak ada bus tersedia untuk rute dan tanggal tersebut.',
            ),
          ),
        );
      }
    } catch (e) {
      print("Error searching buses: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari bus: ${e.toString()}')),
        );
        setState(() {
          isSearchingBus = false;
          foundBuses = [];
        });
      }
    }
  }

  // Widget kustom untuk input field "Dari", "Tujuan", "Tanggal"
  Widget _buildSelectionField({
    required String label,
    String? value,
    required IconData icon,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isDisabled ? Colors.grey.shade500 : const Color(0xFF265AA5),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value ?? label,
                style: GoogleFonts.poppins(
                  color:
                      isDisabled
                          ? Colors.grey.shade500
                          : (value == null
                              ? Colors.grey.shade600
                              : Colors.black87),
                  fontSize: 15.sp,
                  fontWeight:
                      value == null ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
            if (!isDisabled)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade500,
                size: 16.sp,
              ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan item bus
  Widget _buildBusItem(DocumentSnapshot busDoc) {
    final bus = busDoc.data() as Map<String, dynamic>;
    final String jamBus = bus['jam'] ?? 'N/A'; // ✅ Menggunakan field 'jam'
    final int biaya = bus['biaya'] ?? 0;
    final String kelas = bus['kelas'] ?? 'N/A';
    final int totalKursiBusData = bus['jumlah_kursi'] ?? 0;

    // ✅ KOREKSI: Ambil detail bus untuk query pemesanan agar lebih spesifik
    final String asalBus = bus['asal'] ?? '';
    final String tujuanBus = bus['tujuan'] ?? '';
    final String kelasBus = bus['kelas'] ?? '';

    // ✅ PENTING: Gunakan format tanggal "DD Mon BCE" untuk query
    final String tanggalUntukQuery = DateFormat(
      'dd MMM yyyy',
    ).format(selectedDate!);

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman pemilihan kursi untuk admin
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AdminPilihKursiScreen(
                    busData: busDoc, // Meneruskan seluruh dokumen bus
                    // ✅ PENTING: Kirim tanggal dalam format "DD Mon BCE" ke AdminPilihKursiScreen
                    tanggalPemesanan: DateFormat(
                      'dd MMM yyyy',
                    ).format(selectedDate!),
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$jamBus', // ✅ Menggunakan field 'jam'
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF265AA5),
                    ),
                  ),
                  Text(
                    'Rp ${NumberFormat('#,###', 'id_ID').format(biaya)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'Kelas: $kelas',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
              // ✅ FutureBuilder untuk menghitung sisa kursi secara spesifik untuk bus ini
              FutureBuilder<QuerySnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection('pemesanan')
                        .where('asal', isEqualTo: asalBus)
                        .where('tujuan', isEqualTo: tujuanBus)
                        .where(
                          'tanggal',
                          isEqualTo: tanggalUntukQuery,
                        ) // Format tanggal yang konsisten
                        .where(
                          'jam',
                          isEqualTo: jamBus,
                        ) // Filter berdasarkan jam bus ini
                        .where(
                          'kelas',
                          isEqualTo: kelasBus,
                        ) // Filter berdasarkan kelas bus ini
                        .get(),
                builder: (context, snapshot) {
                  int kursiTerpesan = 0;
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      for (var doc in snapshot.data!.docs) {
                        final dataPemesanan =
                            doc.data() as Map<String, dynamic>;
                        kursiTerpesan +=
                            (dataPemesanan['kursi'] as List<dynamic>?)
                                ?.length ??
                            0;
                      }
                    } else if (snapshot.hasError) {
                      debugPrint(
                        "Error fetching booked seats for item: ${snapshot.error}",
                      );
                      return Text(
                        'Error: ${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.red),
                      );
                    }
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      width: 20, // Ukuran indikator loading kecil
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }

                  final int sisaKursi = totalKursiBusData - kursiTerpesan;

                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$sisaKursi Kursi Tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: sisaKursi > 0 ? Colors.orange : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: active ? const Color(0xFF265AA5) : Colors.black54,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: active ? const Color(0xFF265AA5) : Colors.black87,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.poppins(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text(
                'Ya, Keluar',
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF0D4695)),
              child: Center(
                child: Text(
                  'Admin Menu',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20.sp,
                  ),
                ),
              ),
            ),
            _drawerItem(context, Icons.home, 'Beranda', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
              );
            }),
            _drawerItem(context, Icons.directions_bus, 'Kelola Bus', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const KelolaBusScreen()),
              );
            }),
            _drawerItem(context, Icons.people, 'Penumpang', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const KelolaPenumpangScreen(),
                ),
              );
            }),
            // Tandai halaman ini sebagai halaman aktif
            _drawerItem(context, Icons.receipt, 'Pemesanan Manual', () {
              Navigator.pop(
                context,
              ); // Cukup tutup drawer karena sudah di halaman ini
            }, active: true),
            const Divider(thickness: 1, indent: 16, endIndent: 16),
            _drawerItem(context, Icons.logout, 'Sign Out', () {
              Navigator.pop(context);
              _confirmSignOut(context);
            }),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: Text(
          'Pemesanan Manual',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Masukkan detail perjalanan bus",
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),
                _buildSelectionField(
                  label: 'Asal',
                  value: fixedFromCity,
                  icon: Icons.location_on,
                  onTap: () {},
                  isDisabled: true,
                ),
                SizedBox(height: 16.h),
                _buildSelectionField(
                  label: 'Tujuan',
                  value: selectedTo,
                  icon: Icons.location_on_outlined,
                  onTap: _showKotaPicker,
                ),
                SizedBox(height: 16.h),
                _buildSelectionField(
                  label: 'Tanggal Keberangkatan',
                  // ✅ KOREKSI: Tampilan tanggal di UI agar sesuai dengan format "DD Mon BCE"
                  value:
                      selectedDate == null
                          ? null
                          : DateFormat('dd MMM yyyy').format(selectedDate!),
                  icon: Icons.calendar_today_outlined,
                  onTap: _pickDate,
                ),
                SizedBox(height: 30.h),
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed:
                        isLoadingKota || isSearchingBus
                            ? null
                            : () {
                              _searchBuses();
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD100),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 5,
                    ),
                    child:
                        isSearchingBus || isLoadingKota
                            ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                color: Colors.black54,
                                strokeWidth: 2,
                              ),
                            )
                            : Text(
                              "Cari Bus",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
          if (isSearchingBus)
            const Center(child: CircularProgressIndicator())
          else if (foundBuses != null)
            Expanded(
              child:
                  foundBuses!.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            'Tidak ada bus tersedia untuk rute dan tanggal yang dipilih.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        itemCount: foundBuses!.length,
                        itemBuilder: (context, index) {
                          return _buildBusItem(foundBuses![index]);
                        },
                      ),
            ),
        ],
      ),
    );
  }
}
