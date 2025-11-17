import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:etanonapp/core/controllers/auth_controller.dart';
import 'package:etanonapp/core/controllers/news_controller.dart';
import 'package:etanonapp/core/models/news.dart';

class BerandaRT extends StatelessWidget {
  const BerandaRT({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = AuthController();
    final NewsController newsController = NewsController();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      // ❌ HAPUS bagian bottomNavigationBar di sini
      // biarkan RTMain yang menampilkannya

      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, authController),
            const SizedBox(height: 20),
            _buildMainCard(context),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildBeritaSection(context, newsController),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // === HEADER ===
  Widget _buildHeader(BuildContext context, AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF245BCA), Color(0xFF4D7BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.person_rounded, color: Color(0xFF245BCA), size: 35),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hai, Wahyu Nugroho",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                "Selamat datang di E-Tanon Kab. Kediri",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await authController.logout();
              context.go('/auth/login');
            },
          ),
        ],
      ),
    );
  }

// === MAIN CARD (3 KARTU STATISTIK SESUAI GAMBAR) ===
Widget _buildMainCard(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // tetap sama seperti sebelumnya
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
          // === BARIS 1 ===
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  iconPath: 'assets/images/ic_requests.png',
                  title: 'Pengajuan',
                  total: 240,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  iconPath: 'assets/images/ic_news.png',
                  title: 'Surat ditolak',
                  total: 240,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // === BARIS 2 ===
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.42,
                child: _buildStatCard(
                  iconPath: 'assets/images/ic_news.png',
                  title: 'Surat disetujui',
                  total: 240,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// === CARD SESUAI GAMBAR (ICON DI KIRI, TEKS DI SAMPING KANAN, ICON LEBIH BESAR) ===
Widget _buildStatCard({
  required String iconPath,
  required String title,
  required int total,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFE8EEFF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // === ICON BESAR DI KIRI ===
        Image.asset(
          iconPath,
          width: 48,
          height: 48,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),

        // === TEKS DI KANAN (DIBUNGKUS EXPANDED) ===
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                total.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF01002E),
                ),
                overflow: TextOverflow.ellipsis, // aman dari overflow
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF01002E),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  // === BERITA SECTION ===
// === BERITA SECTION (VERTIKAL) ===
Widget _buildBeritaSection(BuildContext context, NewsController newsController) {
  return Padding(
    padding: const EdgeInsets.only(top: 30), // biar agak ke bawah
    child: StreamBuilder<List<News>>(
      stream: newsController.getPublishedNewsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final berita = snapshot.data!.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Header Berita ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berita',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF01002E),
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/rt/berita'),
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
            const SizedBox(height: 14),

            // === List Berita (VERTIKAL) ===
            ListView.separated(
              shrinkWrap: true, // agar muat di dalam scroll parent
              physics: const NeverScrollableScrollPhysics(), // biar gak double scroll
              itemCount: berita.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = berita[index];
                return GestureDetector(
                  onTap: () => context.go(
                    '/rt/berita/detail',
                    extra: {
                      'newsId': item.id,
                      'from': '/rt/beranda', // optional, buat tombol back di detail
                    },
                  ),
                  child: Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // === Thumbnail Kiri ===
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          child: Image.network(
                            item.thumbnail,
                            width: 110,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 110,
                              height: 90,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 40, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // === Teks Berita ===
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF01002E),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.publishedAt != null
                                      ? "${item.publishedAt!.day.toString().padLeft(2, '0')} ${_monthName(item.publishedAt!.month)} ${item.publishedAt!.year}"
                                      : '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    ),
  );
}


  String _monthName(int month) {
    const names = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[month];
  }
}
