import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/pengajuan_controller.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/controllers/auth_controller.dart';
import '../../../../../core/models/request.dart';

class PengajuanSurat extends StatefulWidget {
  const PengajuanSurat({super.key});

  @override
  State<PengajuanSurat> createState() => _PengajuanSuratState();
}

class _PengajuanSuratState extends State<PengajuanSurat> {
  final PengajuanController _pengajuanController = PengajuanController();
  final UserController _userController = UserController();
  final AuthController _authController = AuthController();

  String? _areaId; // area RT yang sedang login
  bool _isLoading = true;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadRtArea();
  }

  Future<void> _loadRtArea() async {
    final user = _authController.currentUser;
    if (user == null) return;

    final rtUser = await _userController.getUserById(user.uid);

    if (!mounted) return; // ✅ Cegah setState setelah widget dispose
    setState(() {
      _areaId = rtUser?.areaId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          // ================= HEADER =================
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
                      'Pengajuan',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF00194A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4E82EA),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Kategori Surat",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Center(
                                    child: Text(
                                      "Detail",
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
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ================= SEARCH BAR =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari RT / RW / Hamlet...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchKeyword = val.trim();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ================= LIST PENGAJUAN =================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _areaId == null
                    ? const Center(child: Text("Data RT tidak ditemukan"))
                    : StreamBuilder<List<Request>>(
                        stream: _searchKeyword.isEmpty
                            ? _pengajuanController.getPengajuanByArea(_areaId!)
                            : _pengajuanController.getPengajuanByAreaKeyword(_searchKeyword),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Belum ada pengajuan surat."));
                          }

                          final pengajuanList = snapshot.data!;
                          // 🔹 Hilangkan duplikat berdasarkan nama kategori (serviceName)
                          final uniqueList = pengajuanList.fold<Map<String, Request>>({}, (map, item) {
                            map[item.serviceName ?? '-'] = item;
                            return map;
                          }).values.toList();

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: uniqueList.length,
                            itemBuilder: (context, index) {
                              final pengajuan = uniqueList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: Row(
                                      children: [
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
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pengajuan.serviceName ?? 'Nama Surat',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF00194A),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              StreamBuilder<int>(
                                                stream: _pengajuanController
                                                    .getTotalPengajuanByArea(pengajuan.areaId),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData) {
                                                    return Text(
                                                      'Total: ...',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.grey[600],
                                                      ),
                                                    );
                                                  }
                                                  final total = snapshot.data ?? 0;
                                                  return Text(
                                                    'Total: $total',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey[600],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.go(
                                              '/rt/detail_pengajuan',
                                              extra: {
                                                'serviceName': pengajuan.serviceName ?? '-',
                                                'areaId': pengajuan.areaId ?? '-',
                                              },
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF00194A),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 18),
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
