import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../models/request.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("requests");
  final supabase = Supabase.instance.client;
  final _firestore = FirebaseFirestore.instance;

  Stream<List<Request>> getRequestsStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final list = data.entries.map((e) {
        final req = Request.fromMap(Map<String, dynamic>.from(e.value), e.key);
        return req;
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Request>> getRequestsByUser(String userId) {
    return getRequestsStream().map(
      (list) => list.where((r) => r.userId == userId).toList(),
    );
  }

  Future<Request?> getRequestById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (!snapshot.exists) return null;
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return Request.fromMap(data, id);
  }

  Future<String> _uploadVerificationFile(File file, String requestId) async {
    try {
      final ext = file.path.split('.').last;
      final fileName = 'verification_${const Uuid().v4()}.$ext';
      final path = 'requests/$requestId/$fileName';
      final bytes = await file.readAsBytes();
      await supabase.storage.from('TanonApp Storage').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(contentType: 'application/pdf'),
      );
      return supabase.storage.from('TanonApp Storage').getPublicUrl(path);
    } catch (e) {
      print('Upload file verifikasi gagal: $e');
      return '';
    }
  }

  Future<void> addRequest({
    required String userId,
    required String serviceId,
    required String areaId,
    String? notes,
  }) async {
    final id = _dbRef.push().key!;
    final request = Request(
      id: id,
      userId: userId,
      serviceId: serviceId,
      areaId: areaId,
      status: 'Diproses',
      verifiedBy: null,
      verifiedAt: null,
      notes: notes ?? '',
      fileUrl: null,
      createdAt: DateTime.now(),
    );
    await _dbRef.child(id).set(request.toMap());
  }

  Future<void> verifyRequest({
    required String id,
    required String verifiedBy,
    required String status,
    String? notes,
    File? verificationFile,
  }) async {
    String? fileUrl;
    if (verificationFile != null) {
      fileUrl = await _uploadVerificationFile(verificationFile, id);
    }
    await _dbRef.child(id).update({
      'status': status,
      'verifiedBy': verifiedBy,
      'verifiedAt': DateTime.now().toIso8601String(),
      'notes': notes ?? '',
      'fileUrl': fileUrl,
    });
  }

  Future<void> cancelRequest({
    required String id,
    required String reason,
  }) async {
    await _dbRef.child(id).update({
      'status': 'Dibatalkan',
      'notes': reason,
    });
  }

  Future<void> downloadVerificationFile(String url) async {
    if (url.isEmpty) return;
    if (kIsWeb) {
      if (!await launchUrl(Uri.parse(url))) {
        throw Exception('Tidak bisa membuka $url');
      }
    } else {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission tidak diberikan');
      }
      final dio = Dio();
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory("/storage/emulated/0/Download");
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }
      if (downloadDir == null) {
        throw Exception('Tidak bisa akses folder download');
      }
      final name = url.split('/').last;
      final savePath = '${downloadDir.path}/$name';
      try {
        await dio.download(url, savePath);
      } catch (e) {
        print('Download gagal: $e');
      }
    }
  }

  Future<String> getServiceName(String id) async {
    if (id.isEmpty) return "-";
    final doc = await _firestore.collection('services').doc(id).get();
    if (!doc.exists) return "-";
    return doc.data()?['name'] ?? "-";
  }

  Stream<int> getTotalRequests() {
    return getRequestsStream().map((list) => list.length);
  }
}