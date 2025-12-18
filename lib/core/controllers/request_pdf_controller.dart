import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../models/request.dart';
import '../models/user.dart';
import '../models/area.dart';
import '../models/service.dart';

class RequestPDFController {

  Future<dynamic> generateSuratPengantarPDF({
    required Map<String, dynamic> user,
    required Map<String, dynamic> area,
    required Map<String, dynamic> service,
    required String requestId,
    required String verifiedBy,
  }) async {
    final pdf = pw.Document();

    final rt = area["rt"] ?? "-";
    final rw = area["rw"] ?? "-";
    final dusun = area["hamlet"] ?? "-";

    final username = user["username"] ?? "-";
    final ttl = user["birthPlaceDate"] ?? "-";
    final agama = user["religion"] ?? "-";
    final warga = user["nationality"] ?? "-";
    final nik = user["nik"] ?? "-";
    final pekerjaan = user["occupation"] ?? "-";
    final statusKawin = user["maritalStatus"] ?? "-";
    final serviceName = service["name"] ?? "-";

    /// LOGO
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo-kab.png'))
          .buffer
          .asUint8List(),
    );

    /// ===============================
    /// DATA BARCODE
    /// ===============================
    final barcodeData =
        "SURAT-TANON|$username|$requestId|$verifiedBy|${DateTime.now().toIso8601String()}";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              /// ===== HEADER =====
              pw.Center(
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Image(logo, width: 60, height: 60),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("PEMERINTAH KABUPATEN KEDIRI",
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text("KECAMATAN PAPAR",
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text("KANTOR KEPALA DESA TANON",
                            style: pw.TextStyle(fontSize: 12)),
                        pw.Text(
                          "DUSUN ${dusun.toUpperCase()}",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  "SURAT PENGANTAR",
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Yang bertanda tangan di bawah ini Ketua RT $rt / RW $rw Dusun $dusun, "
                "memohon kepada Ibu/Bapak Kepala Desa untuk dapatnya dilayani bagi warga kami:",
                style: pw.TextStyle(fontSize: 12),
              ),

              pw.SizedBox(height: 12),

              _buildRow("Nama", username),
              _buildRow("Tempat/Tgl Lahir", ttl),
              _buildRow("Agama", agama),
              _buildRow("Kewarganegaraan", warga),
              _buildRow("Nomor KTP", nik),
              _buildRow("Pekerjaan", pekerjaan),
              _buildRow("Alamat", "RT $rt / RW $rw Dusun $dusun"),
              _buildRow("Status Perkawinan", statusKawin),

              pw.SizedBox(height: 20),
              pw.Text("Adapun kebutuhan yang diperlukan:",
                  style: pw.TextStyle(fontSize: 12)),
              pw.Text(serviceName, style: pw.TextStyle(fontSize: 12)),

              pw.SizedBox(height: 30),

              /// ===== BARCODE =====
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Text(_formatDate(DateTime.now()),
                        style: pw.TextStyle(fontSize: 12)),
                    pw.Text("Ketua RT",
                        style: pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 8),

                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: barcodeData,
                      width: 90,
                      height: 90,
                    ),

                    pw.SizedBox(height: 6),
                    pw.Text(verifiedBy,
                        style: pw.TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      return pdfBytes;
    } else {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/surat_$requestId.pdf");
      await file.writeAsBytes(pdfBytes);
      return file;
    }
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label)),
          pw.Text(": "),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const bulan = [
      "Januari","Februari","Maret","April","Mei","Juni",
      "Juli","Agustus","September","Oktober","November","Desember"
    ];
    return "${date.day} ${bulan[date.month - 1]} ${date.year}";
  }

  Future<void> exportRequestsPdf({
    required List<Request> requests,
    required Map<String, User> users,
    required Map<String, Area> areas,
    required Map<String, Service> services,
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text("Laporan Data Pengajuan",
              style: pw.TextStyle(fontSize: 18)),
        ],
      ),
    );
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
