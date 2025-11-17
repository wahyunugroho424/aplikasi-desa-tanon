import 'package:flutter/material.dart';

class DesaDataRequestsPage extends StatelessWidget {
  const DesaDataRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        title: const Text('Data Pengajuan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF00194A),
      ),
      body: const Center(
        child: Text(
          'Ini Page Data Pengguna',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
