import 'package:flutter/material.dart';

class InfoKeberangkatanScreen extends StatelessWidget {
  final List<Map<String, String>> busSchedule = [
    {'bus': 'Bus A', 'time': '08:00', 'destination': 'Jakarta'},
    {'bus': 'Bus B', 'time': '09:30', 'destination': 'Bandung'},
    {'bus': 'Bus C', 'time': '11:00', 'destination': 'Surabaya'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Informasi Keberangkatan')),
      body: ListView.builder(
        itemCount: busSchedule.length,
        itemBuilder: (context, index) {
          final schedule = busSchedule[index];
          return ListTile(
            leading: Icon(Icons.directions_bus),
            title: Text(schedule['bus']!),
            subtitle: Text('Tujuan: ${schedule['destination']}'),
            trailing: Text(schedule['time']!),
          );
        },
      ),
    );
  }
}
