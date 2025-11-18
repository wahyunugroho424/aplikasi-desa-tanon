import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/models/request.dart';
import '../../../../../core/models/user.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class DesaDataRequestsDetailPage extends StatefulWidget {
  final String id;
  const DesaDataRequestsDetailPage({super.key, required this.id});

  @override
  State<DesaDataRequestsDetailPage> createState() => _DesaDataRequestsDetailPageState();
}

class _DesaDataRequestsDetailPageState extends State<DesaDataRequestsDetailPage> {
  final requestController = RequestController();
  final userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: SafeArea(
        child: FutureBuilder<Request?>(
          future: requestController.getRequestById(widget.id),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final req = snap.data!;
            return FutureBuilder<User?>(
              future: userController.getUserById(req.userId),
              builder: (context, userSnap) {
                if (!userSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = userSnap.data!;
                return _buildContent(req, user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(Request req, User user) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Detail Pengajuan',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00194A),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _detailItem("Tanggal", "${req.createdAt.day}/${req.createdAt.month}/${req.createdAt.year}"),

                      FutureBuilder<String>(
                        future: requestController.getServiceName(req.serviceId),
                        builder: (context, snapshot) {
                          return _detailItem("Layanan", snapshot.data ?? "-");
                        },
                      ),

                      _detailItem("Nama Pengaju", user.username),

                      FutureBuilder<String>(
                        future: userController.getFullAddress(user.areaId),
                        builder: (context, snapshot) {
                          return _detailItem("Alamat", snapshot.data ?? "-");
                        },
                      ),

                      _detailItem("Status", req.status),
                      _detailItem("Catatan", req.notes ?? "-"),
                      _detailItem("Verifikator", req.verifiedBy ?? "-"),

                      _detailItem(
                        "Waktu Verifikasi",
                        req.verifiedAt == null
                            ? "-"
                            : "${req.verifiedAt!.day}/${req.verifiedAt!.month}/${req.verifiedAt!.year} "
                              "${req.verifiedAt!.hour}:${req.verifiedAt!.minute}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                if (req.fileUrl != null) ...[
                  Text(
                    "File Verifikasi",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF245BCA),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FutureBuilder<String>(
                        future: _downloadPdfToLocal(req.fileUrl!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              height: 350,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(),
                            );
                          }

                          return PDFView(
                            filePath: snapshot.data!,
                            enableSwipe: true,
                            swipeHorizontal: true,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF245BCA),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      requestController.downloadVerificationFile(req.fileUrl!);
                    },
                    child: Text(
                      "Download PDF",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).alignCenter(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _downloadPdfToLocal(String url) async {
    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.pdf";

    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final file = File(filePath);
    await file.writeAsBytes(response.data);

    return filePath;
  }
Widget _detailItem(String title, String value) {
  return Container(
    margin: const EdgeInsets.only(bottom: 18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF245BCA),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}

extension AlignCenter on Widget {
  Widget alignCenter() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [this],
      );
}