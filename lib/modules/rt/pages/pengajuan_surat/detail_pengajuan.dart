import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/pengajuan_controller.dart';
import '../../../../../core/models/request.dart';

class DetailPengajuan extends StatelessWidget {
  final String serviceName;
  final String areaId;

  const DetailPengajuan({
    super.key,
    required this.serviceName,
    required this.areaId,
  });

  Future<String> _getUsername(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data()!.containsKey('username')) {
        return doc.data()!['username'];
      }
      return 'Nama Tidak Diketahui';
    } catch (e) {
      return 'Nama Tidak Diketahui';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFF4E82EA);
      case 'selesai':
        return const Color(0xFF1ABC9C);
      case 'ditolak':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final PengajuanController pengajuanController = PengajuanController();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          // ===== HEADER =====
          Stack(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_top.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Detail Pengajuan',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TAB BAR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            // 🔹 TAB KIRI: Kategori Surat (navigasi ke pengajuan_surat.dart)
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Pindah ke halaman kategori surat
                                  context.go('/rt/pengajuan');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Kategori Surat",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF00194A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 🔹 TAB KANAN: Detail (aktif)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4E82EA),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Center(
                                  child: Text(
                                    "Detail",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ===== LIST DETAIL PENGAJUAN =====
          Expanded(
            child: StreamBuilder<List<Request>>(
              stream: pengajuanController.getPengajuanByArea(areaId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = snapshot.data!
                    .where((r) => r.serviceName == serviceName)
                    .toList();

                if (list.isEmpty) {
                  return const Center(
                    child: Text("Belum ada warga yang mengajukan surat ini."),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final pengajuan = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EFFF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            // 🟦 Logo
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 3,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/images/pesan.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 🟩 Nama & Status
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _getUsername(pengajuan.userId),
                                builder: (context, nameSnapshot) {
                                  final username =
                                      nameSnapshot.data ?? 'Memuat...';
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF00194A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pengajuan.status ?? '-',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: _statusColor(
                                              pengajuan.status ?? ''),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            // Tombol kanan
                          ElevatedButton(
                            onPressed: () {
                              // Arahkan ke halaman detail data pengajuan
                              context.go('/rt/detail_data/pengajuan?id=${pengajuan.id}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00194A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                            ),
                            child: Text(
                              "Check",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
