import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request.dart';
import '../models/area.dart';

class PengajuanController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("requests");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil semua pengajuan surat sesuai areaId (RT)
  Stream<List<Request>> getPengajuanByArea(String areaId) {
    return _dbRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final list = await Future.wait(data.entries.map((e) async {
        final req = Request.fromMap(Map<String, dynamic>.from(e.value), e.key);

        // Ambil nama surat dari Firestore
        String? serviceName;
        if (req.serviceId.isNotEmpty) {
          final serviceDoc = await _firestore.collection('services').doc(req.serviceId).get();
          if (serviceDoc.exists) {
            serviceName = serviceDoc.data()?['name'];
          }
        }

        return req.copyWith(serviceName: serviceName ?? '-');
      }));

      // Filter: hanya ambil pengajuan sesuai areaId
      final filtered = list.where((r) => r.areaId.trim().toLowerCase() == areaId.trim().toLowerCase()).toList();

      // Urutkan dari terbaru ke lama
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filtered;
    });
  }

  /// Ambil pengajuan berdasarkan keyword Area (RT, RW, Hamlet)
  Stream<List<Request>> getPengajuanByAreaKeyword(String keyword) {
    keyword = keyword.toLowerCase();

    // Ambil semua area yang cocok keyword
    final areaStream = _firestore.collection('areas').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Area.fromMap(data);
      }).where((area) =>
          area.rt.toLowerCase().contains(keyword) ||
          area.rw.toLowerCase().contains(keyword) ||
          area.hamlet.toLowerCase().contains(keyword)
      ).toList();
    });

    // Gabungkan area yang cocok dengan pengajuan
    return areaStream.asyncMap((filteredAreas) async {
      final allRequests = await getAllPengajuan().first;

      final allowedAreaIds = filteredAreas.map((a) => a.id).toList();

      final filteredRequests = allRequests.where((r) => allowedAreaIds.contains(r.areaId)).toList();

      // Urutkan dari terbaru ke lama
      filteredRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return filteredRequests;
    });
  }

  /// Ambil semua pengajuan (tanpa filter)
  Stream<List<Request>> getAllPengajuan() {
    return _dbRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final list = await Future.wait(data.entries.map((e) async {
        final req = Request.fromMap(Map<String, dynamic>.from(e.value), e.key);

        // Ambil nama surat dari Firestore
        String? serviceName;
        if (req.serviceId.isNotEmpty) {
          final serviceDoc = await _firestore.collection('services').doc(req.serviceId).get();
          if (serviceDoc.exists) {
            serviceName = serviceDoc.data()?['name'];
          }
        }

        return req.copyWith(serviceName: serviceName ?? '-');
      }));

      // Urutkan dari terbaru ke lama
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Ambil 1 pengajuan berdasarkan ID
  Future<Request?> getPengajuanById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final req = Request.fromMap(data, id);

    // Ambil nama surat dari Firestore
    String? serviceName;
    if (req.serviceId.isNotEmpty) {
      final serviceDoc = await _firestore.collection('services').doc(req.serviceId).get();
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

  /// ================= TOTAL PENGAJUAN =================

  /// Hitung total semua pengajuan
  Stream<int> getTotalPengajuan() {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      return data.length;
    });
  }

  /// Hitung total pengajuan berdasarkan areaId
  Stream<int> getTotalPengajuanByArea(String areaId) {
    return getPengajuanByArea(areaId).map((list) => list.length);
  }

  /// Hitung total pengajuan berdasarkan keyword area
  Stream<int> getTotalPengajuanByAreaKeyword(String keyword) {
    return getPengajuanByAreaKeyword(keyword).map((list) => list.length);
  }


/// ================= TOTAL PENGAJUAN DISSETUJUI =================
/// Hitung total pengajuan dengan status "Disetujui" berdasarkan areaId
  Stream<int> getTotalDisetujuiByArea(String areaId) {
    return _dbRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};

      // Filter: hanya pengajuan dengan areaId sesuai dan status "Disetujui"
      final disetujuiList = data.entries.where((e) {
        final map = Map<String, dynamic>.from(e.value);
        final status = map['status']?.toString().toLowerCase() ?? '';
        final area = map['areaId']?.toString().toLowerCase() ?? '';
        return area == areaId.toLowerCase() && status == 'disetujui';
      }).toList();

      return disetujuiList.length;
    });
  }

  Stream<int> getTotalDitolakByArea(String areaId) {
  return _dbRef.onValue.map((event) {
    final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
    final ditolakList = data.entries.where((e) {
      final map = Map<String, dynamic>.from(e.value);
      final status = map['status']?.toString().toLowerCase() ?? '';
      final area = map['areaId']?.toString().toLowerCase() ?? '';
      return area == areaId.toLowerCase() && status == 'ditolak';
    }).toList();
    return ditolakList.length;
  });
}




}
