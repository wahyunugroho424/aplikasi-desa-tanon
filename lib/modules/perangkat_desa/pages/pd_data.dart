import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/controllers/service_controller.dart';
import '../../../../../core/controllers/news_controller.dart';
import '../../../../../core/controllers/area_controller.dart';
import '../../../../../core/controllers/request_controller.dart';

class DesaDataPage extends StatefulWidget {
  const DesaDataPage({super.key});

  @override
  State<DesaDataPage> createState() => _DesaDataPageState();
}

class _DesaDataPageState extends State<DesaDataPage> {
  final userController = UserController();
  final serviceController = ServiceController();
  final newsController = NewsController();
  final areaController = AreaController();
  final requestController = RequestController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_top.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Data Master',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF00194A),
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 70),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StreamBuilder<int>(
                    stream: userController.getTotalUsers(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return _buildDataCard(
                        title: 'Data Pengguna',
                        iconPath: 'assets/images/ic_users.png',
                        total: total,
                        color: const Color(0xFFCEDDFF),
                        buttonColor: const Color(0xFF00194A),
                        buttonTextColor: Colors.white,
                        onPressed: () => context.push('/pd/data/users'),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StreamBuilder<int>(
                    stream: areaController.getTotalAreas(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return _buildDataCard(
                        title: 'Data Wilayah',
                        iconPath: 'assets/images/ic_users.png',
                        total: total,
                        color: const Color(0xFFCEDDFF),
                        buttonColor: const Color(0xFF00194A),
                        buttonTextColor: Colors.white,
                        onPressed: () => context.push('/pd/data/areas'),
                      );
                    },
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StreamBuilder<int>(
                    stream: serviceController.getTotalServices(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return _buildDataCard(
                        title: 'Data Keperluan',
                        iconPath: 'assets/images/ic_services.png',
                        total: total,
                        color: const Color(0xFF4E82EA),
                        buttonColor: const Color(0xFFCEDDFF),
                        buttonTextColor: const Color(0xFF01002E),
                        onPressed: () => context.push('/pd/data/services'),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StreamBuilder<int>(
                    stream: requestController.getTotalRequests(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;

                      return _buildDataCard(
                        title: 'Data Pengajuan',
                        iconPath: 'assets/images/ic_requests.png',
                        total: total,
                        color: const Color(0xFFCEDDFF),
                        buttonColor: const Color(0xFF00194A),
                        buttonTextColor: Colors.white,
                        onPressed: () => context.push('/pd/data/requests'),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: StreamBuilder<int>(
                    stream: newsController.getTotalNews(),
                    builder: (context, snapshot) {
                      final total = snapshot.data ?? 0;
                      return _buildDataCard(
                        title: 'Data Berita',
                        iconPath: 'assets/images/ic_news.png',
                        total: total,
                        color: const Color(0xFF4E82EA),
                        buttonColor: const Color(0xFFCEDDFF),
                        buttonTextColor: const Color(0xFF01002E),
                        onPressed: () => context.push('/pd/data/news'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required String iconPath,
    required int total,
    required Color color,
    required Color buttonColor,
    required Color buttonTextColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              iconPath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00194A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total data: $total',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00194A),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Check',
                        style: GoogleFonts.poppins(
                          color: buttonTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
