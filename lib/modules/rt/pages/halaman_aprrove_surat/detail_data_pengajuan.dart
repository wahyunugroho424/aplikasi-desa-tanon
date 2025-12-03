import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/models/request.dart';

class DetailDataPengajuanPage extends StatelessWidget {
  final String requestId;

  const DetailDataPengajuanPage({
    super.key,
    required this.requestId,
  });

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // 🔥 Tambahkan untuk ambil data area
  Future<Map<String, dynamic>?> _getAreaData(String areaId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('areas').doc(areaId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // 🔥 Tambahkan untuk ambil data SERVICE berdasarkan serviceId
  Future<Map<String, dynamic>?> _getServiceData(String serviceId) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final RequestController requestController = RequestController();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: FutureBuilder<Request?>(
        future: requestController.getRequestById(requestId),
        builder: (context, requestSnapshot) {
          if (requestSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final request = requestSnapshot.data;
          if (request == null) {
            return const Center(child: Text("Data pengajuan tidak ditemukan."));
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserData(request.userId),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = userSnapshot.data ?? {};

              // 🔥 Ambil area berdasarkan areaId
              return FutureBuilder<Map<String, dynamic>?>(
                future: _getAreaData(request.areaId),
                builder: (context, areaSnapshot) {
                  if (areaSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final area = areaSnapshot.data ?? {};

                  // 🔥 Ambil data service berdasarkan serviceId
                  return FutureBuilder<Map<String, dynamic>?>(
                    future: _getServiceData(request.serviceId),
                    builder: (context, serviceSnapshot) {
                      if (serviceSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final service = serviceSnapshot.data ?? {};
                      final serviceName = service["name"] ?? "-";
                      final List<dynamic> requirements =
                          service["requirements"] ?? [];

                      return Scaffold(
                        backgroundColor: const Color(0xFFF2F6FF),
                        appBar: AppBar(
                          backgroundColor: const Color(0xFFF2F6FF),
                          elevation: 0,
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
                            onPressed: () {
                              context.go(
                                '/rt/detail_pengajuan',
                                extra: {
                                  // 🔥 Sebelumnya pakai request.serviceName, sekarang serviceName asli
                                  'serviceName': serviceName,
                                  'areaId': request.areaId ?? '-',
                                },
                              );
                            },
                          ),
                          title: Text(
                            "Lihat Pengajuan",
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF00194A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          centerTitle: true,
                        ),

                        body: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "DATA KEPERLUAN",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: const Color(0xFF00194A),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 🔥 Pakai serviceName dari Firestore
                              _buildDropdownField("Keperluan", serviceName),
                              const SizedBox(height: 12),

                              // 🔥 GANTI PERSYARATAN: sekarang pakai service.requirements
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PERSYARATAN YANG DIPERLUKAN",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: const Color(0xFF00194A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // 🔥 Convert List<String> → bullet text
                                    Text(
                                      requirements.map((r) => "- $r").join("\n"),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              Text(
                                "DATA PRIBADI PENGAJU",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: const Color(0xFF00194A),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildTextField("NIK", user["nik"]),
                              const SizedBox(height: 10),

                              _buildTextField("Tempat, tanggal lahir", user["birthPlaceDate"]),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(child: _buildTextField("RT", area["rt"])),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildTextField("RW", area["rw"])),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildTextField("DUSUN", area["hamlet"])),
                                ],
                              ),

                              const SizedBox(height: 10),
                              _buildTextField("KEWARGANEGARAAN", user["nationality"]),
                              const SizedBox(height: 10),
                              _buildTextField("AGAMA", user["religion"]),
                              const SizedBox(height: 10),
                              _buildTextField("PEKERJAAN", user["occupation"]),
                              const SizedBox(height: 10),
                              _buildTextField("STATUS PERKAWINAN", user["maritalStatus"]),
                              const SizedBox(height: 24),

                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await requestController.verifyRequestAutoPDF(
                                          request: request,
                                          user: user,
                                          area: area,
                                          service: service,
                                        );

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Surat berhasil dibuat & disimpan!")),
                                        );
                                      },

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF245BCA),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        "Disetujui",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await requestController.verifyRequest(
                                          id: request.id,
                                          verifiedBy: "RT",
                                          status: "Ditolak",
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                              content: Text("Pengajuan ditolak ❌")),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          side:
                                              const BorderSide(color: Color(0xFF245BCA)),
                                        ),
                                      ),
                                      child: Text(
                                        "Ditolak",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF245BCA),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTextField(String label, dynamic value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value?.toString() ?? "-"),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: GoogleFonts.poppins(fontSize: 13),
    );
  }

  Widget _buildDropdownField(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }
}
