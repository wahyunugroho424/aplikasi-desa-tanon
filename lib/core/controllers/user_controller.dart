import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'package:flutter/material.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = "users";

  Stream<List<User>> getUsersStream() {
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromMap(data);
      }).toList();
    });
  }

  Stream<int> getTotalUsers() {
    return getUsersStream().map((list) => list.length);
  }

  Future<User?> getUserById(String id) async {
    final doc = await _firestore.collection(collectionName).doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return User.fromMap(data);
    }
    return null;
  }

  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    String id = _firestore.collection(collectionName).doc().id;

    final user = User(
      id: id,
      nik: '',
      username: username.trim(),
      email: email.trim(),
      password: password.trim(),
      role: role.trim(),
      birthPlaceDate: '',
      religion: '',
      nationality: '',
      occupation: '',
      maritalStatus: '',
      areaId: '',
      phone: '',
    );

    await _firestore.collection(collectionName).doc(id).set(user.toMap());
  }

  Future<void> updateUser({
    required String id,
    required String nik,
    required String username,
    required String email,
    required String password,
    required String birthPlace,
    required String birthDate,
    required String religion,
    required String nationality,
    required String occupation,
    required String maritalStatus,
    required String areaId,
    required String phone,
    required String role,
  }) async {
    final user = User(
      id: id,
      nik: nik.trim(),
      username: username.trim(),
      email: email.trim(),
      password: password.trim(),
      birthPlaceDate: '$birthPlace, $birthDate',
      religion: religion.trim(),
      nationality: nationality.trim(),
      occupation: occupation.trim(),
      maritalStatus: maritalStatus.trim(),
      areaId: areaId.trim(),
      phone: phone.trim(),
      role: role.trim(),
    );

    await _firestore.collection(collectionName).doc(id).update(user.toMap());
  }

  Future<void> updateUserPartial({
    required String id,
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final user = User(
      id: id,
      nik: '',
      username: username.trim(),
      email: email.trim(),
      password: password.trim(),
      role: role.trim(),
      birthPlaceDate: '',
      religion: '',
      nationality: '',
      occupation: '',
      maritalStatus: '',
      areaId: '',
      phone: '',
    );

    await _firestore.collection(collectionName).doc(id).update(user.toMap());
  }

  Future<void> deleteUser(String id) async {
    await _firestore.collection(collectionName).doc(id).delete();
  }
  
  Stream<List<User>> getFilteredUsersStream(String keyword) {
    keyword = keyword.toLowerCase();
    return _firestore.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromMap(data);
      }).where((user) => user.username.toLowerCase().contains(keyword)).toList();
    });
  }

  Future<List<User>> getUsersByRole(String role) async {
    final querySnapshot = await _firestore
        .collection(collectionName)
        .where('role', isEqualTo: role)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return User.fromMap(data);
    }).toList();
  }

  Future<String> getUsernameById(String userId) async {
    try {
      final doc = await _firestore.collection(collectionName).doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('username')) {
          return data['username'] ?? 'Tidak diketahui';
        }
      }
      return 'Tidak ditemukan';
    } catch (e) {
      debugPrint('Error mengambil username: $e');
      return 'Error';
    }
  }

  Future<String> getFullAddress(String areaId) async {
    try {
      final doc = await _firestore.collection('areas').doc(areaId).get();
      if (!doc.exists) return '-';
      final data = doc.data()!;
      final rt = data['rt'] ?? '-';
      final rw = data['rw'] ?? '-';
      final hamlet = data['hamlet'] ?? '-';
      return 'RT $rt/RW $rw Dusun $hamlet';
    } catch (e) {
      debugPrint('Error getFullAddress: $e');
      return '-';
    }
  }

  Future<List<Map<String, dynamic>>> getHamletList() async {
    final snapshot = await _firestore.collection('areas').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRwList(String hamletName) async {
    final snapshot = await _firestore
        .collection('areas')
        .where('hamlet', isEqualTo: hamletName) // pakai nama hamlet
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getRtList(String hamletName, String rw) async {
    final snapshot = await _firestore
        .collection('areas')
        .where('hamlet', isEqualTo: hamletName)
        .where('rw', isEqualTo: rw)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> updateUserSignature({
    required String userId,
    required String signatureUrl,
  }) async {
    await _firestore.collection(collectionName).doc(userId).update({
      'signature': signatureUrl,
    });
  }

}