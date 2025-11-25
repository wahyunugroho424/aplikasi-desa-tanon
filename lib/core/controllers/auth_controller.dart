import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': username.trim(),
        'email': email.trim(),
        'role': 'Warga',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await credential.user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (!credential.user!.emailVerified) {
        await _auth.signOut();
        return 'Email belum diverifikasi. Silakan cek email untuk verifikasi.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> handleLogin({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    final error = await login(
      email: emailController.text,
      password: passwordController.text,
    );
    setLoading(false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      final role = userDoc.data()!['role'] ?? 'Perangkat Desa';

      if (role == 'Warga') {
        context.go('/wg/beranda');
      } else if (role == 'RT') {
        context.go('/rt/beranda');
      } else {
        context.go('/pd/beranda');
      }
    } else {
      context.go('/pd/beranda');
    }
  }

  Future<void> handleRegister({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    final error = await register(
      username: usernameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    setLoading(false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Registrasi berhasil! Cek email untuk verifikasi.'),
      ));
      context.go('/auth/login');
    }
  }

  Future<void> handleResetPassword({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    final error = await resetPassword(emailController.text);
    setLoading(false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Link reset password telah dikirim ke email Anda.'),
      ));
      context.go('/auth/login');
    }
  }

  bool isAuthRoute(String path) {
    return path == '/auth/login' ||
        path == '/auth/register' ||
        path == '/auth/forgot-password';
  }

  String? redirectLogic(String path) {
    final user = _auth.currentUser;
    final loggingIn = isAuthRoute(path);

    if (user == null && !loggingIn) return '/auth/login';
    if (user != null && !user.emailVerified && !loggingIn) {
      return '/auth/login';
    }
    if (user != null && user.emailVerified && loggingIn) return '/pd/beranda';

    return null; 
  }

  String? _cachedRole; 

  Future<void> cacheUserRole() async {
    final user = currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      _cachedRole = doc.data()?['role'] ?? 'Perangkat Desa';
    }
  }

  String get currentUserRole => _cachedRole ?? 'Perangkat Desa';

  String getRoutePrefix() {
  final role = currentUserRole;
  if (role == 'Perangkat Desa') return 'pd';
  if (role == 'Warga') return 'wg';
  if (role == 'RT') return 'rt';
  return 'wg'; 
}

Future<Map<String, dynamic>> getCurrentUserData() async {
  final user = currentUser;
  if (user == null) return {
  'username': 'RT',
    'areaId': '',
  };

  final doc = await _firestore.collection('users').doc(user.uid).get();
  final data = doc.data() ?? {};
  return {
    'username': data['username'] ?? 'RT User',
    'areaId': data['areaId'] ?? '',
  };
}


}