import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'pesan_tiket_screen.dart';
import 'informasi_jadwal_bus.dart'; // Ini mungkin harus diubah namanya jika sudah dihapus
import 'profile.dart';
import 'pilih_bus.dart'; // Pastikan path ini benar

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? userName;
  String? selectedFrom;
  String? selectedTo;
  DateTime? selectedDate;
  final TextEditingController searchController = TextEditingController();

  List<String> kotaAsal = [];
  List<String> kotaTujuan = [];
  bool isLoadingKota = true;

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchKotaFromFirebase();
    // SystemChrome.setSystemUIOverlayStyle removed from here as it's set globally in main.dart
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
            primaryColor: const Color(0xFF265AA5), // Warna header date picker
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF265AA5), // Warna yang dipilih
              onPrimary: Colors.white, // Warna teks pada tanggal yang dipilih
              surface: Colors.white, // Background kalender
              onSurface: Colors.black, // Warna teks kalender
            ),
            dialogBackgroundColor:
                Colors.white, // Background dialog date picker
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

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      setState(() {
        userName = doc.data()?['displayName'] ?? 'Pengguna';
      });
    }
  }

  Future<void> fetchKotaFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('buses').get();
    final Set<String> asalSet = {};
    final Set<String> tujuanSet = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('asal')) asalSet.add(data['asal']);
      if (data.containsKey('tujuan')) tujuanSet.add(data['tujuan']);
    }

    setState(() {
      kotaAsal = asalSet.toList();
      kotaTujuan = tujuanSet.toList();
      isLoadingKota = false;
    });
  }

  void _showKotaPicker(bool isFromField) {
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
                final List<String> daftarKota =
                    isFromField ? kotaAsal : kotaTujuan;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            onChanged: (_) => setStateModal(() {}),
                            decoration: InputDecoration(
                              hintText: 'Masukkan nama kota',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              suffixIcon:
                                  searchController.text.isNotEmpty
                                      ? IconButton(
                                        icon: Icon(Icons.clear),
                                        onPressed: () {
                                          searchController.clear();
                                          setStateModal(() {});
                                        },
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child:
                          daftarKota.isEmpty
                              ? Center(child: Text('Tidak ada kota tersedia.'))
                              : ListView(
                                children:
                                    daftarKota
                                        .where(
                                          (city) => city.toLowerCase().contains(
                                            searchController.text.toLowerCase(),
                                          ),
                                        )
                                        .map(
                                          (city) => ListTile(
                                            title: Text(city),
                                            onTap: () {
                                              setState(() {
                                                if (isFromField) {
                                                  selectedFrom = city;
                                                } else {
                                                  selectedTo = city;
                                                }
                                              });
                                              Navigator.pop(context);
                                            },
                                          ),
                                        )
                                        .toList(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    // --- Header Section ---
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF265AA5), // Warna biru gelap
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        24.w,
                        24.h + MediaQuery.of(context).padding.top,
                        24.w,
                        32.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Halo, ${userName ?? 'Pengguna'}!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Navigasi ke halaman profil
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileScreen(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 20.r,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF265AA5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Mau kemana hari ini?',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16.sp,
                            ),
                          ),
                          // Start of updated spacing: Reduced spacing before booking box
                          SizedBox(height: 16.h), // Mengurangi dari 24.h
                          // End of updated spacing
                        ],
                      ),
                    ),
                    // --- End Header Section ---

                    // --- Booking Box Section (The modernized part) ---
                    Transform.translate(
                      offset: Offset(
                        0,
                        -30.h,
                      ), // Mengangkat box ke atas agar tumpang tindih dengan header biru
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 24.w,
                        ), // Margin dari samping
                        padding: EdgeInsets.all(20.w), // Padding internal
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            24.r,
                          ), // Sudut yang lebih membulat
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10), // Bayangan lebih dramatis
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // "Dari" field
                            _buildBookingField(
                              label: 'Dari',
                              value: selectedFrom,
                              icon: Icons.location_on,
                              onTap: () => _showKotaPicker(true),
                            ),
                            SizedBox(height: 12.h), // Spacing
                            // Swap button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  final temp = selectedFrom;
                                  selectedFrom = selectedTo;
                                  selectedTo = temp;
                                });
                              },
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 4.w),
                                child: Icon(
                                  Icons.swap_vert,
                                  color: Colors.grey.shade600,
                                  size: 28.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h), // Spacing
                            // "Tujuan" field
                            _buildBookingField(
                              label: 'Tujuan',
                              value: selectedTo,
                              icon: Icons.location_on_outlined,
                              onTap: () => _showKotaPicker(false),
                            ),
                            SizedBox(height: 20.h), // More spacing before date
                            // Date field
                            _buildBookingField(
                              label: 'Tanggal Keberangkatan',
                              value:
                                  selectedDate == null
                                      ? "Tanggal keberangkatan"
                                      : "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
                              icon: Icons.calendar_today,
                              onTap: _pickDate,
                            ),
                            SizedBox(height: 24.h), // Spacing before button
                            // Search Bus button
                            SizedBox(
                              width: double.infinity,
                              height: 54.h, // Tinggi tombol lebih besar
                              child: ElevatedButton(
                                onPressed:
                                    isLoadingKota
                                        ? null // Disable if still loading cities
                                        : () {
                                          if (selectedFrom != null &&
                                              selectedTo != null &&
                                              selectedDate != null) {
                                            final formattedDate = 
                                            "${selectedDate!.day.toString().padLeft(2, '0')} ${_monthName(selectedDate!.month)} ${selectedDate!.year}";
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => PilihBusScreen(
                                                      asal: selectedFrom!,
                                                      tujuan: selectedTo!,
                                                      tanggal: formattedDate,
                                                    ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Harap lengkapi semua detail perjalanan.',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFFFFD100,
                                  ), // Warna kuning cerah
                                  foregroundColor:
                                      Colors.black, // Warna teks hitam
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      20.r,
                                    ), // Sudut lebih membulat
                                  ),
                                  elevation: 5, // Tambah sedikit elevasi
                                ),
                                child:
                                    isLoadingKota
                                        ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          child:
                                              const CircularProgressIndicator(
                                                color: Colors.black54,
                                                strokeWidth: 2,
                                              ),
                                        )
                                        : Text(
                                          "Cari Bus",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- End Booking Box Section ---

                    // Start of updated spacing: Reduced spacing between booking box and history section
                    SizedBox(height: 0.h), // Mengurangi dari 20.h
                    // End of updated spacing

                    // --- Riwayat Section ---
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        24.w, // Konsisten dengan padding box
                        0, // Hapus padding top di sini
                        24.w, // Konsisten dengan padding box
                        4.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Riwayat",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PesanTiketScreen(),
                                ),
                              );
                            },
                            icon: Icon(Icons.arrow_forward_ios, size: 14.sp),
                            label: Text(
                              "Lihat Semua",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('pemesanan')
                              .where(
                                'uid',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser?.uid,
                              )
                              .orderBy('dipesan_pada', descending: true)
                              .limit(3)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 24.h),
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/not_file.png",
                                  width: 100.w,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  "Belum ada Riwayat Pemesanan",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40.w,
                                  ),
                                  child: Text(
                                    "Belum ada riwayat pemesanan tiket bus. Pesan tiket sekarang untuk memulai perjalanan Anda!",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!.docs[index];
                            final String asal = data['asal'];
                            final String tujuan = data['tujuan'];
                            final String kode = data['kode_pemesanan'];
                            final int total = data['total_pembayaran'] ?? 0;

                            return Container(
                              // Margin horizontal 24.w untuk konsistensi dengan padding utama
                              // Margin vertikal tetap 8.h agar tidak terlalu rapat antar item
                              margin: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 4.h,
                              ),
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6.r,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$asal → $tujuan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "Kode: $kode",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    "Total Pembayaran: Rp$total",
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF265AA5),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_num),
            label: 'Tiket',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  // --- Widget Kustom untuk Picker (Dari, Tujuan, Tanggal) ---
  Widget _buildBookingField({
    required String label,
    String? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF265AA5), size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value == null ? Colors.grey.shade600 : Colors.black87,
                  fontSize: 15.sp,
                  fontWeight:
                      value == null ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ),
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
  // --- End Widget Kustom ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PesanTiketScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileScreen()),
        );
        break;
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }
}
