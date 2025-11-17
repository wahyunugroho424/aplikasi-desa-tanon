import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import '../models/news.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class NewsController {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child("news");
  final supabase = Supabase.instance.client;

  Stream<List<News>> getNewsStream() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final list = data.entries.map((e) {
        return News.fromMap(Map<String, dynamic>.from(e.value), e.key);
      }).toList();

      list.sort((a, b) {
        final aDate = a.publishedAt ?? DateTime(0);
        final bDate = b.publishedAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      });

      return list;
    });
  }

  Stream<int> getTotalNews() {
    return getNewsStream().map((list) => list.length);
  }

  Stream<List<News>> getPublishedNewsStream() {
    return getNewsStream().map(
      (list) => list.where((news) => news.publishedAt != null).toList(),
    );
  }

  Stream<List<News>> getFilteredNewsStream(String keyword) {
    final k = keyword.toLowerCase();
    return getNewsStream().map(
      (list) => list
          .where((news) => news.title.toLowerCase().contains(k))
          .toList(),
    );
  }

  Future<News?> getNewsById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return News.fromMap(data, id);
    }
    return null;
  }

  Future<String> _uploadThumbnail(File file, String newsId) async {
    try {
      final fileName = 'thumbnail_${const Uuid().v4()}${_extensionFromPath(file.path)}';
      final path = 'news/$newsId/$fileName';
      final bytes = await file.readAsBytes();

      await supabase.storage.from('TanonApp Storage').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/png'),
      );

      final url = supabase.storage.from('TanonApp Storage').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Upload thumbnail gagal: $e');
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _uploadFiles(List<File> files, String newsId) async {
    final List<Map<String, dynamic>> uploaded = [];
    for (final f in files) {
      try {
        final name = f.path.split('/').last;
        final path = 'news/$newsId/files/$name';
        final bytes = await f.readAsBytes();
        await supabase.storage.from('TanonApp Storage').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'application/octet-stream'),
        );
        final url = supabase.storage.from('TanonApp Storage').getPublicUrl(path);
        uploaded.add({'name': name, 'url': url});
      } catch (e) {
        print('Upload file ${f.path} gagal: $e');
      }
    }
    return uploaded;
  }

  Future<String> _uploadPlatformThumbnail(PlatformFile file, String newsId) async {
    try {
      final fileName = 'thumbnail_${const Uuid().v4()}${_extensionFromPath(file.name)}';
      final path = 'news/$newsId/$fileName';
      if (file.bytes == null) throw Exception('Thumbnail bytes kosong');

      await supabase.storage.from('TanonApp Storage').uploadBinary(path, file.bytes!);
      final url = supabase.storage.from('TanonApp Storage').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Upload thumbnail gagal: $e');
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _uploadPlatformFiles(List<PlatformFile> files, String newsId) async {
    final List<Map<String, dynamic>> uploaded = [];
    for (final f in files) {
      try {
        if (f.bytes == null) continue;
        final path = 'news/$newsId/files/${f.name}';
        await supabase.storage.from('TanonApp Storage').uploadBinary(path, f.bytes!);
        final url = supabase.storage.from('TanonApp Storage').getPublicUrl(path);
        uploaded.add({'name': f.name, 'url': url});
      } catch (e) {
        print('Upload file ${f.name} gagal: $e');
      }
    }
    return uploaded;
  }

  String _extensionFromPath(String p) {
    final idx = p.lastIndexOf('.');
    if (idx == -1) return '';
    return p.substring(idx);
  }

  Future<void> addNews({
    required String title,
    required String content,
    required String userId,
    required String status,
    File? thumbnailFile,
    List<File>? supportingFiles,
    PlatformFile? platformThumbnail,
    List<PlatformFile>? platformFiles,
  }) async {
    final id = _dbRef.push().key!;
    String thumbnailUrl = '';
    List<Map<String, dynamic>> files = [];

    if (platformThumbnail != null) {
      thumbnailUrl = await _uploadPlatformThumbnail(platformThumbnail, id);
    } else if (thumbnailFile != null) {
      thumbnailUrl = await _uploadThumbnail(thumbnailFile, id);
    }

    if (platformFiles != null && platformFiles.isNotEmpty) {
      files = await _uploadPlatformFiles(platformFiles, id);
    } else if (supportingFiles != null && supportingFiles.isNotEmpty) {
      files = await _uploadFiles(supportingFiles, id);
    }

    DateTime? publishedAt;
    if (status == 'Publish') publishedAt = DateTime.now();

    final news = News(
      id: id,
      title: title.trim(),
      thumbnail: thumbnailUrl,
      content: content.trim(),
      userId: userId,
      status: status,
      files: files,
      publishedAt: publishedAt,
    );

    await _dbRef.child(id).set(news.toMap());
  }

  Future<void> updateNews({
    required String id,
    required String title,
    required String content,
    required String userId,
    required String status,
    File? newThumbnailFile,
    List<File>? newSupportingFiles,
    PlatformFile? newPlatformThumbnail,
    List<PlatformFile>? newPlatformFiles,
  }) async {
    final snapshot = await _dbRef.child(id).get();
    if (!snapshot.exists) throw Exception('News not found');

    final current = News.fromMap(
        Map<String, dynamic>.from(snapshot.value as Map), snapshot.key!);

    String thumbnailUrl = current.thumbnail;
    List<Map<String, dynamic>> files = List.from(current.files);

    if (newPlatformThumbnail != null) {
      thumbnailUrl = await _uploadPlatformThumbnail(newPlatformThumbnail, id);
    } else if (newThumbnailFile != null) {
      thumbnailUrl = await _uploadThumbnail(newThumbnailFile, id);
    }

    if (newPlatformFiles != null && newPlatformFiles.isNotEmpty) {
      final uploaded = await _uploadPlatformFiles(newPlatformFiles, id);
      files.addAll(uploaded);
    } else if (newSupportingFiles != null && newSupportingFiles.isNotEmpty) {
      final uploaded = await _uploadFiles(newSupportingFiles, id);
      files.addAll(uploaded);
    }

    DateTime? publishedAt = current.publishedAt;
    if (status == 'Publish' && publishedAt == null) publishedAt = DateTime.now();
    if (status != 'Publish') publishedAt = null;

    final updated = News(
      id: id,
      title: title.trim(),
      thumbnail: thumbnailUrl,
      content: content.trim(),
      userId: userId,
      status: status,
      files: files,
      publishedAt: publishedAt,
    );

    await _dbRef.child(id).update(updated.toMap());
  }

  Future<void> deleteNews(String id) async {
    try {
      final snapshot = await _dbRef.child(id).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final thumb = data['thumbnail'] as String?;
        if (thumb != null && thumb.isNotEmpty) {
          try {
            await _deleteStorageFileByUrl(thumb);
          } catch (_) {}
        }
        final files = (data['files'] as List?) ?? [];
        for (final f in files) {
          final url = (f as Map)['url'] as String?;
          if (url != null && url.isNotEmpty) {
            try {
              await _deleteStorageFileByUrl(url);
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    await _dbRef.child(id).remove();
  }

  Future<void> _deleteStorageFileByUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('TanonApp Storage');
      final path = segments.sublist(bucketIndex + 1).join('/');
      await supabase.storage.from('TanonApp Storage').remove([path]);
    } catch (e) {
      throw Exception('Gagal hapus file: $e');
    }
  }

  Future<void> downloadNewsFiles(List<Map<String, dynamic>> files) async {
    if (files.isEmpty) return;

    if (kIsWeb) {
      for (final f in files) {
        final url = f['url'] as String;
        if (url.isNotEmpty) {
          if (!await launchUrl(Uri.parse(url))) {
            throw Exception('Tidak bisa membuka $url');
          }
        }
      }
    } else {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission tidak diberikan');
      }

      final dio = Dio();
      Directory? downloadDir;

      if (Platform.isAndroid) {
        downloadDir = await getExternalStorageDirectory();
        final path = "/storage/emulated/0/Download";
        downloadDir = Directory(path);
      } else if (Platform.isIOS) {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) throw Exception('Tidak bisa akses folder download');

      for (final f in files) {
        final url = f['url'] as String;
        final name = f['name'] as String;
        final savePath = '${downloadDir.path}/$name';

        try {
          await dio.download(url, savePath);
        } catch (e) {
          print('Download $name gagal: $e');
        }
      }
    }
  }
}