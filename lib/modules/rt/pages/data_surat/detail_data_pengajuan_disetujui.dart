import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/models/request.dart';

class DetailDataPengajuanDisetujuiPage extends StatelessWidget {
  final String requestId;

  const DetailDataPengajuanDisetujuiPage({
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

  Color _statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'disetujui':
      return const Color(0xFF1ABC9C); // hijau
    case 'diproses':
      return const Color(0xFF4E82EA); // biru
    case 'ditolak':
      return const Color(0xFFE74C3C); // merah
    default:
      return Colors.grey; // default abu-abu
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

              return Scaffold(
                backgroundColor: const Color(0xFFF2F6FF),
                appBar: AppBar(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
                    onPressed: () {
                      // Balik ke halaman DetailDisetujuiPage dengan parameter
                      context.go(
                        '/rt/detail_disetujui',
                        extra: {
                          'serviceName': request.serviceName ?? '-',
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

                // ================= BODY =================
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
                      _buildDropdownField("Keperluan", request.serviceName ?? "-"),
                      const SizedBox(height: 12),

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
                            Text(
                              "- Fotokopi KK/akte anggota keluarga\n"
                              "- Fotokopi buku nikah/akta perkawinan jika sudah menikah\n"
                              "- Fotokopi ijazah terakhir jika bersekolah\n"
                              "- Fotokopi surat pindah anggota keluarga",
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
                      Row(
                        children: [
                          Expanded(child: _buildTextField("TEMPAT LAHIR", user["birthPlace"])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField("TANGGAL LAHIR", user["birthDate"])),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildTextField("JENIS KELAMIN", user["gender"]),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildTextField("RT", user["rt"])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField("RW", user["rw"])),
                          const SizedBox(width: 10),
                          Expanded(child: _buildTextField("DUSUN", user["dusun"])),
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
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _statusColor(request.status ?? 'pending'),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  request.status ?? '-',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
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


// LOGO  PEMERINTAH KABUPATEN KEDIRI
//       KECAMATAN PAPAR
//       KANTOR KEPALA DESA TANON
//       DUSUN {areas.hamlet}->capital
// -------------------------------------

// SURAT PENGANTAR

// Yang bertanda tangan di bawah ini Ketua RT {areas.rt} RW {areas.rw} Dusun {areas.hamlet},
// dengan ini mohon dengan hormat kepada Ibu/Bapak Kepala Desa untuk dapatnya dilayani bagi warga kami:
// Nama      : {users.username}
// Tempat/Tgl Lahir  : {users.birthPlaceDate}
// Agama     : {users.religion}
// Kewarganegaraan     : {users.nationality}
// Nomor KTP     : - KOSONG DULU AJA KARENA LUPA BELUM ADA KOLOM DATANYA
// Pekerjaan     : {users.occupation}
// Alamat     : RT {areas.rt} RW {areas.rw} Dusun {areas.hamlet}
// Status Perkawinan     : {users.maritalStatus}

// Adapun kebutuhan yang diperlukan sebagai berikut:
// {services.name}

// Demikian untuk menjadikan maklum dan terima kasih atas bantuannya.

// Mengetahui
// {requests.verifiedAt}
// Ketua RT {areas.rt}


// {users.username}