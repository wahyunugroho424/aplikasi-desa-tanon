import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/models/request.dart';

class WargaPengajuanDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const WargaPengajuanDetailPage({super.key, required this.data});

  @override
  State<WargaPengajuanDetailPage> createState() => _WargaPengajuanDetailPageState();
}

class _WargaPengajuanDetailPageState extends State<WargaPengajuanDetailPage> {
  final _controller = RequestController();
  Request? _request;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    final id = widget.data['id'];
    if (id != null) {
      final req = await _controller.getRequestById(id);
      setState(() {
        _request = req;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F6FF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final req = _request;
    if (req == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF2F6FF),
        body: Center(child: Text("Data pengajuan tidak ditemukan")),
      );
    }

    final requestName = req.serviceName ?? '-';
    final status = req.status;
    final tanggalPengajuan = DateFormat('dd MMMM yyyy', 'id_ID').format(req.createdAt);
    final tanggalVerifikasi = req.verifiedAt != null
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(req.verifiedAt!)
        : '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Container(
              height: 190,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg_beranda.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00194A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem("Tanggal Pengajuan", tanggalPengajuan),
                            _buildInfoItem("Tanggal Verifikasi", tanggalVerifikasi),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Status Pengajuan",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF00194A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                status,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Builder(
                            builder: (context) {
                              final lowerStatus = status.toLowerCase();

                              if (lowerStatus == 'disetujui' || lowerStatus == 'selesai') {
                                return _buildButton(
                                  color: const Color(0xFF245BCA),
                                  icon: Icons.download_rounded,
                                  label: "Unduh Pengajuan",
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Sedang mengunduh...',
                                          style: GoogleFonts.poppins(color: Colors.white),
                                        ),
                                        backgroundColor: const Color(0xFF245BCA),
                                      ),
                                    );
                                    await _controller.downloadVerificationFile(req.fileUrl ?? '');
                                  },
                                );
                              } else if (lowerStatus == 'ditolak' || lowerStatus == 'dibatalkan') {
                                return _buildButton(
                                  color: Colors.red[700]!,
                                  icon: Icons.info_outline_rounded,
                                  label: "Lihat Catatan",
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20)),
                                        title: Text('Catatan',
                                            style:
                                                GoogleFonts.poppins(fontSize: 18, color: Colors.red[700])),
                                        content: Text(
                                          (req.notes ?? '').isNotEmpty
                                              ? req.notes!
                                              : 'Tidak ada catatan tambahan.',
                                          style: GoogleFonts.poppins(fontSize: 13),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Tutup',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.red[700])),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else if (lowerStatus == 'diproses') {
                                return _buildButton(
                                  color: Colors.red[700]!,
                                  icon: Icons.cancel_outlined,
                                  label: "Batalkan Pengajuan",
                                  onPressed: () async {
                                    final reasonController = TextEditingController();
                                    String? errorText;

                                    await showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            title: Text('Batalkan Pengajuan',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600)),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Tuliskan alasan pembatalan pengajuan:',
                                                  style: GoogleFonts.poppins(fontSize: 13),
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: reasonController,
                                                  decoration: InputDecoration(
                                                    hintText: 'Masukkan alasan pembatalan...',
                                                    hintStyle: GoogleFonts.poppins(
                                                        fontSize: 13, color: Colors.grey),
                                                    errorText: errorText,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                    ),
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text('Tutup',
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.grey[700])),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red[700]),
                                                onPressed: () async {
                                                  if (reasonController.text
                                                      .trim()
                                                      .isEmpty) {
                                                    setState(() {
                                                      errorText =
                                                          'Alasan pembatalan wajib diisi';
                                                    });
                                                    return;
                                                  }

                                                  await _controller.cancelRequest(
                                                    id: req.id,
                                                    reason: reasonController.text.trim(),
                                                  );
                                                  if (mounted) {
                                                    Navigator.of(context).pop();
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'Pengajuan berhasil dibatalkan',
                                                          style: GoogleFonts.poppins(
                                                              color: Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                    context.go('/wg/pengajuan');
                                                  }
                                                },
                                                child: Text('Batalkan Pengajuan',
                                                    style: GoogleFonts.poppins(
                                                        color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                        Text(
                          "---------- DETAIL STATUS ----------",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                  _buildTimelineItem(tanggalPengajuan, "Pengajuan dibuat", true),
                  _buildTimelineItem(tanggalVerifikasi, "Verifikasi RT", true),
                  _buildTimelineItem("-", "Pengajuan selesai", false),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/wg/pengajuan'),
                ),
                Text('Detail Riwayat',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF00194A), fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white, size: 20),
      label: Text(
        label,
        style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
      Text(value,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildTimelineItem(String date, String title, bool isActive) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
    child: Row(
      children: [
        Column(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF245BCA)
                        : Colors.grey[400],
                    shape: BoxShape.circle)),
            Container(width: 2, height: 40, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date,
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600])),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFF00194A)
                          : Colors.grey[600]
                  )
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
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