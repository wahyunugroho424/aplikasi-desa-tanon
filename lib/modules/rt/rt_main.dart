import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RTMain extends StatefulWidget {
  final Widget child;
  const RTMain({super.key, required this.child});

  @override
  State<RTMain> createState() => _RTMainState();
}

class _RTMainState extends State<RTMain> {
  int _selectedIndex = 0;

  // 🔹 Daftar route sesuai urutan BottomNavigationBar
  final List<String> _routes = [
    '/rt/beranda',
    '/rt/pengajuan', // ← ini akan menampilkan PengajuanSurat
    '/rt/laporan',
    '/rt/akun',
  ];

  // 🔹 Saat tab diklik
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    // Navigasi ke rute berdasarkan index
    context.go(_routes[index]);
  }

  // 🔹 Deteksi halaman aktif berdasarkan path sekarang
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/rt/pengajuan')) {
      return 1;
    } else if (location.startsWith('/rt/laporan')) {
      return 2;
    } else if (location.startsWith('/rt/akun')) {
      return 3;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    _selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF245BCA),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page_rounded),
            label: 'Pengajuan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}