import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;

class RequestPDFController {
  Future<dynamic> generateSuratPengantarPDF({
    required Map<String, dynamic> user,
    required Map<String, dynamic> area,
    required Map<String, dynamic> service,
    required String requestId,
  }) async {
    final pdf = pw.Document();

    final rt = area["rt"] ?? "-";
    final rw = area["rw"] ?? "-";
    final dusun = area["hamlet"] ?? "-";

    final username = user["username"] ?? "-";
    final ttl = user["birthPlaceDate"] ?? "-";
    final agama = user["religion"] ?? "-";
    final warga = user["nationality"] ?? "-";
    final pekerjaan = user["occupation"] ?? "-";
    final statusKawin = user["maritalStatus"] ?? "-";
    final serviceName = service["name"] ?? "-";

    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo-kab.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Row(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Image(logo, width: 60, height: 60),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("PEMERINTAH KABUPATEN KEDIRI", style: pw.TextStyle(fontSize: 12)),
                        pw.Text("KECAMATAN PAPAR", style: pw.TextStyle(fontSize: 12)),
                        pw.Text("KANTOR KEPALA DESA TANON", style: pw.TextStyle(fontSize: 12)),
                        pw.Text("DUSUN ${dusun.toUpperCase()}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  "SURAT PENGANTAR",
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
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
              _buildRow("Nomor KTP", "-"),
              _buildRow("Pekerjaan", pekerjaan),
              _buildRow("Alamat", "RT $rt / RW $rw Dusun $dusun"),
              _buildRow("Status Perkawinan", statusKawin),
              pw.SizedBox(height: 20),
              pw.Text("Adapun kebutuhan yang diperlukan sebagai berikut:", style: pw.TextStyle(fontSize: 12)),
              pw.Text(serviceName, style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text("Demikian untuk menjadikan maklum dan terima kasih atas bantuannya.", style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 40),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(_formatDate(DateTime.now()), style: pw.TextStyle(fontSize: 12)),
                    pw.Text("Ketua RT $rt", style: pw.TextStyle(fontSize: 12)),
                    pw.SizedBox(height: 40),
                    pw.Text(username, style: pw.TextStyle(fontSize: 12)),
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
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(width: 150, child: pw.Text(label, style: pw.TextStyle(fontSize: 12))),
          pw.Text(": ", style: pw.TextStyle(fontSize: 12)),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(fontSize: 12))),
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
}
