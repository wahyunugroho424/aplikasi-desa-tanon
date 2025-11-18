import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/area.dart';

class AreaController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "areas";

  Stream<List<Area>> getAreasStream() {
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Area.fromMap(data);
      }).toList();
    });
  }

  Stream<int> getTotalAreas() {
    return getAreasStream().map((list) => list.length);
  }

  Future<Area?> getAreaById(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return Area.fromMap(data);
    }
    return null;
  }

  Future<void> addArea({
    required String rt,
    required String rw,
    required String hamlet,
    required String userId,
  }) async {
    String id = _firestore.collection(collectionName).doc().id;

    final area = Area(
      id: id,
      rt: rt.trim(),
      rw: rw.trim(),
      hamlet: hamlet.trim(),
      userId: userId,
    );

    await _firestore.collection(collectionName).doc(id).set(area.toMap());
  }

  Future<void> updateArea({
    required String id,
    required String rt,
    required String rw,
    required String hamlet,
    required String userId,
  }) async {
    final area = Area(
      id: id,
      rt: rt.trim(),
      rw: rw.trim(),
      hamlet: hamlet.trim(),
      userId: userId,
    );

    await _firestore.collection(collectionName).doc(id).update(area.toMap());
  }

  Future<void> deleteArea(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }

  Stream<List<Area>> getFilteredAreasStream(String keyword) {
    keyword = keyword.toLowerCase();
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Area.fromMap(data);
      }).where((area) =>
          area.rt.toLowerCase().contains(keyword) ||
          area.rw.toLowerCase().contains(keyword) ||
          area.hamlet.toLowerCase().contains(keyword)).toList();
    });
  }
}