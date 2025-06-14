import 'package:flutter/material.dart';

class InformasiJadwalBusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi Jadwal Bus'),
      ),
      body: Center(
        child: Text(
          'Halaman Informasi Jadwal Bus',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
