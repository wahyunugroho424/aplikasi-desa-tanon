import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/models/request.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WargaPengajuanPage extends StatefulWidget {
  const WargaPengajuanPage({super.key});

  @override
  State<WargaPengajuanPage> createState() => _WargaPengajuanPageState();
}

class _WargaPengajuanPageState extends State<WargaPengajuanPage> {
  int selectedTabIndex = 0;

  final _requestController = RequestController();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 125,
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
                child: Column(
                  children: [
                    Text(
                      'Pengajuan',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00194A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedTabIndex = 0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedTabIndex == 0
                                        ? const Color(0xFF4E82EA)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sedang Berlangsung',
                                      style: GoogleFonts.poppins(
                                        color: selectedTabIndex == 0
                                            ? Colors.white
                                            : const Color(0xFF00194A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => selectedTabIndex = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selectedTabIndex == 1
                                        ? const Color(0xFF4E82EA)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Riwayat',
                                      style: GoogleFonts.poppins(
                                        color: selectedTabIndex == 1
                                            ? Colors.white
                                            : const Color(0xFF00194A),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
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

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<Request>>(
              stream: _requestController.getRequestsByUser(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada pengajuan.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  );
                }

                final requests = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final item = requests[index];

                      if (selectedTabIndex == 0 && item.status != 'Diproses') {
                        return const SizedBox.shrink();
                      }
                      if (selectedTabIndex == 1 && item.status == 'Diproses') {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildPengajuanCard(item),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/wg/pengajuan/add'),
        backgroundColor: const Color(0xFF245BCA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPengajuanCard(Request item) {
    return GestureDetector(
      onTap: () {
        context.push(
          '/wg/pengajuan/detail',
          extra: {
            'id': item.id,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFCEDDFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00194A), width: 1.5),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/images/list_services.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text(
            item.serviceName ?? '-',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00194A),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              item.status,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _statusColor(item.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'disetujui':
        return Colors.green[700]!;
      case 'ditolak':
        return Colors.red[700]!;
      case 'diproses':
        return const Color(0xFF245BCA);
      case 'dibatalkan':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}