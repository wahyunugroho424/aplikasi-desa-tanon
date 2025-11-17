import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/controllers/service_controller.dart';
import '../../../../../core/controllers/news_controller.dart';
import '../../../../../core/models/news.dart';

class WargaBerandaPage extends StatelessWidget {
  final userController = UserController();
  final newsController = NewsController();
  final serviceController = ServiceController();
  WargaBerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(45),
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/bg_beranda.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF4E82EA),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hai, Safira Nabila',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Selamat datang di E-Tanon Kab. Kediri',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 150),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildMainCard(context),
                  const SizedBox(height: 20),
                  _buildBeritaSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StreamBuilder<int>(
                  stream: userController.getTotalUsers(),
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0;
                    return _buildSmallCard(
                      context: context,
                      iconPath: 'assets/images/ic_users.png',
                      title: 'Pengguna',
                      total: total,
                      color: const Color(0xFFCEDDFF),
                      route: '/pd/data/users',
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<int>(
                  stream: serviceController.getTotalServices(),
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0;
                    return _buildSmallCard(
                      context: context,
                      iconPath: 'assets/images/ic_services.png',
                      title: 'Keperluan',
                      total: total,
                      color: const Color(0xFFCEDDFF),
                      route: '/pd/data/services',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSmallCard(
                  context: context,
                  iconPath: 'assets/images/ic_requests.png',
                  title: 'Pengajuan',
                  total: 12,
                  color: const Color(0xFFCEDDFF),
                  route: '/data/requests',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StreamBuilder<int>(
                  stream: newsController.getTotalNews(),
                  builder: (context, snapshot) {
                    final total = snapshot.data ?? 0;
                    return _buildSmallCard(
                      context: context,
                      iconPath: 'assets/images/ic_news.png',
                      title: 'Berita',
                      total: total,
                      color: const Color(0xFFCEDDFF),
                      route: '/pd/data/news',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard({
    required BuildContext context,
    required String iconPath,
    required String title,
    required int total,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 30, height: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    total.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF01002E),
                    ),
                  ),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF01002E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBeritaSection(BuildContext context) {
    return StreamBuilder<List<News>>(
      stream: newsController.getPublishedNewsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final berita = snapshot.data!.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berita Terbaru',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01002E),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/wg/berita'),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF245BCA),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: berita.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = berita[index];
                  return GestureDetector(
                    onTap: () => context.go(
                      '/wg/berita/detail',
                      extra: item.id,
                    ),
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: Image.network(
                              item.thumbnail,
                              width: 140,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 140,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF01002E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.publishedAt != null
                                      ? "${item.publishedAt!.day.toString().padLeft(2,'0')} ${_monthName(item.publishedAt!.month)} ${item.publishedAt!.year}, ${item.publishedAt!.hour.toString().padLeft(2,'0')}:${item.publishedAt!.minute.toString().padLeft(2,'0')}"
                                      : '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return names[month];
  }
}