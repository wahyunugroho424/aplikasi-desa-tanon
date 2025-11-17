import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PerangkatDesaMain extends StatefulWidget {
  final Widget child;
  const PerangkatDesaMain({super.key, required this.child});

  @override
  State<PerangkatDesaMain> createState() => _PerangkatDesaMainState();
}

class _PerangkatDesaMainState extends State<PerangkatDesaMain> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/pd/beranda',
    '/pd/data',
    '/pd/berita',
    '/pd/akun',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_routes[index]);
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/pd/data')) {
      return 1;
    } else if (location.startsWith('/pd/berita')) {
      return 2;
    } else if (location.startsWith('/pd/akun')) {
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
        selectedItemColor: const Color.fromARGB(255, 36, 91, 202),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Data Master',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded),
            label: 'Berita',
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