import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';
import '../models/area.dart';

class PengajuanController {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child("requests");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================
  // ================== AMBIL DATA PENGAJUAN =================
  // =========================================================

  /// Ambil semua pengajuan berdasarkan areaId (RT)
  Stream<List<Request>> getPengajuanByArea(String areaId) {
    return _dbRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final list = await Future.wait(
        data.entries.map((e) async {
          final req =
              Request.fromMap(Map<String, dynamic>.from(e.value), e.key);

          String? serviceName;
          if (req.serviceId.isNotEmpty) {
            final serviceDoc =
                await _firestore.collection('services').doc(req.serviceId).get();
            if (serviceDoc.exists) {
              serviceName = serviceDoc.data()?['name'];
            }
          }

          return req.copyWith(serviceName: serviceName ?? '-');
        }),
      );

      final filtered = list
          .where((r) =>
              r.areaId.trim().toLowerCase() ==
              areaId.trim().toLowerCase())
          .toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  /// Ambil semua pengajuan (tanpa filter)
  Stream<List<Request>> getAllPengajuan() {
    return _dbRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final list = await Future.wait(
        data.entries.map((e) async {
          final req =
              Request.fromMap(Map<String, dynamic>.from(e.value), e.key);

          String? serviceName;
          if (req.serviceId.isNotEmpty) {
            final serviceDoc =
                await _firestore.collection('services').doc(req.serviceId).get();
            if (serviceDoc.exists) {
              serviceName = serviceDoc.data()?['name'];
            }
          }

          return req.copyWith(serviceName: serviceName ?? '-');
        }),
      );

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Cari pengajuan berdasarkan keyword RT / RW / Dusun
  Stream<List<Request>> getPengajuanByAreaKeyword(String keyword) {
    keyword = keyword.toLowerCase();

    final areaStream = _firestore.collection('areas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Area.fromMap(data);
      }).where((area) =>
          area.rt.toLowerCase().contains(keyword) ||
          area.rw.toLowerCase().contains(keyword) ||
          area.hamlet.toLowerCase().contains(keyword)).toList();
    });

    return areaStream.asyncMap((areas) async {
      final all = await getAllPengajuan().first;
      final allowedIds = areas.map((a) => a.id).toList();

      final filtered =
          all.where((r) => allowedIds.contains(r.areaId)).toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return filtered;
    });
  }

  /// Ambil satu pengajuan
  Future<Request?> getPengajuanById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final req = Request.fromMap(data, id);

    String? serviceName;
    if (req.serviceId.isNotEmpty) {
      final serviceDoc =
          await _firestore.collection('services').doc(req.serviceId).get();
      if (serviceDoc.exists) {
        serviceName = serviceDoc.data()?['name'];
      }
    }

    return req.copyWith(serviceName: serviceName ?? '-');
  }

  /// Update status pengajuan
  Future<void> updateStatus({
    required String id,
    required String status,
    String? notes,
  }) async {
    await _dbRef.child(id).update({
      'status': status,
      'notes': notes ?? '',
      'verifiedAt': DateTime.now().toIso8601String(),
    });
  }

  // =========================================================
  // ====================== TOTAL PENGAJUAN ==================
  // =========================================================

  /// Total semua pengajuan berdasarkan areaId
  Stream<int> getTotalPengajuanByArea(String areaId) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['areaId']?.toString().toLowerCase() ==
            areaId.toLowerCase();
      }).length;
    });
  }

  /// Total pengajuan berdasarkan area & kategori
  Stream<int> getTotalPengajuanByAreaAndCategory(
    String areaId,
    String categoryId,
  ) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['areaId']?.toString().toLowerCase() ==
                areaId.toLowerCase() &&
            map['serviceId']?.toString() == categoryId;
      }).length;
    });
  }

  // =========================================================
  // ====================== TOTAL DITOLAK ====================
  // =========================================================

  Stream<int> getTotalDitolakByArea(String areaId) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['status']?.toString().toLowerCase() == 'ditolak' &&
            map['areaId']?.toString().toLowerCase() ==
                areaId.toLowerCase();
      }).length;
    });
  }

  Stream<int> getTotalDitolakByAreaAndCategory(
    String areaId,
    String categoryId,
  ) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['status']?.toString().toLowerCase() == 'ditolak' &&
            map['areaId']?.toString().toLowerCase() ==
                areaId.toLowerCase() &&
            map['serviceId']?.toString() == categoryId;
      }).length;
    });
  }

  // =========================================================
  // ===================== TOTAL DISETUJUI ===================
  // =========================================================

  Stream<int> getTotalDisetujuiByArea(String areaId) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['status']?.toString().toLowerCase() == 'disetujui' &&
            map['areaId']?.toString().toLowerCase() ==
                areaId.toLowerCase();
      }).length;
    });
  }

  Stream<int> getTotalDisetujuiByAreaAndCategory(
    String areaId,
    String categoryId,
  ) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      return data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        return map['status']?.toString().toLowerCase() == 'disetujui' &&
            map['areaId']?.toString().toLowerCase() ==
                areaId.toLowerCase() &&
            map['serviceId']?.toString() == categoryId;
      }).length;
    });
  }
}
