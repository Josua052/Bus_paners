import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pesan_tiket_screen.dart';
import 'informasi_jadwal_bus.dart';
import 'profile.dart';
import 'pilih_bus.dart';

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ScreenUtilInit(
                designSize: const Size(375, 812),
                builder:
                    (context, child) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF265AA5),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(24.r),
                                  bottomRight: Radius.circular(24.r),
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                24.h + MediaQuery.of(context).padding.top,
                                16.w,
                                24.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/logo_app.png',
                                        width: 40.w,
                                        height: 40.w,
                                      ),
                                      SizedBox(width: 12.w),
                                      Flexible(
                                        child: Text(
                                          'Halo, ${userName ?? '...'}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Container(
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildCustomPicker(
                                          'Dari',
                                          selectedFrom,
                                          () => _showKotaPicker(true),
                                        ),
                                        SizedBox(height: 12.h),
                                        _buildCustomPicker(
                                          'Tujuan',
                                          selectedTo,
                                          () => _showKotaPicker(false),
                                        ),
                                        SizedBox(height: 12.h),
                                        InkWell(
                                          onTap: _pickDate,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 16.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey.shade400,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_city_outlined,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 10.w),
                                                Expanded(
                                                  child: Text(
                                                    selectedDate == null
                                                        ? "Tanggal keberangkatan"
                                                        : "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
                                                    style: TextStyle(
                                                      color:
                                                          selectedDate == null
                                                              ? Colors.grey
                                                              : Colors.black,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16.h),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
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
                                                          tanggal:
                                                              formattedDate,
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFFFFD100,
                                              ),
                                              foregroundColor: const Color(
                                                0xFF265AA5,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                vertical: 16.h,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.r),
                                              ),
                                            ),
                                            child: Text(
                                              "Cari Bus",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900],
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                24.h,
                                16.w,
                                8.h,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        MaterialPageRoute(builder: (_) => PesanTiketScreen()),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14.sp,
                                    ),
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
                            // ✅ SOROT PEMBARUAN INI
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('pemesanan')
                                  .where('uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                                  .orderBy('dipesan_pada', descending: true) // Ganti 'created_at' jika kamu menggunakan 'dipesan_pada'
                                  .limit(3) // Maksimal 3 riwayat
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 24.h),
                                    child: Column(
                                      children: [
                                        Image.asset("assets/images/not_file.png", width: 100.w),
                                        SizedBox(height: 12.h),
                                        Text(
                                          "Belum ada Riwayat Pemesanan",
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 8.h),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 40.w),
                                          child: Text(
                                            "Belum ada riwayat pemesanan tiket bus. Pesan tiket sekarang untuk memulai perjalanan Anda!",
                                            style: TextStyle(fontSize: 13.sp, color: Colors.black54),
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
                                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16.r),
                                        border: Border.all( // 🟨 DITAMBAHKAN UNTUK STROKE KOTAK
                                          color: Colors.grey.shade300,
                                          width: 10,
                                        ),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: Offset(0, 2))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("$asal → $tujuan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                          SizedBox(height: 6.h),
                                          Text("Kode: $kode", style: TextStyle(fontSize: 14.sp, color: Colors.black54)),
                                          SizedBox(height: 4.h),
                                          Text("Total Pembayaran: Rp$total", style: TextStyle(fontSize: 14.sp)),
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
                    ),
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white, // ✅ warna putih solid
          elevation: 0, // ✅ tanpa bayangan
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
      ),
    );
  }

  Widget _buildCustomPicker(String label, String? value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.location_city_outlined, color: Colors.grey),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value == null ? Colors.grey : Colors.black,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0:
      // Tidak perlu navigasi, karena sudah di halaman ini
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

  String _dayName(int weekday) {
    const days = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday];
  }
}
