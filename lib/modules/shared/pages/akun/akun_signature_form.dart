import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/controllers/user_controller.dart';

class AkunSignaturePage extends StatefulWidget {
  const AkunSignaturePage({super.key});

  @override
  State<AkunSignaturePage> createState() => _AkunSignaturePageState();
}

class _AkunSignaturePageState extends State<AkunSignaturePage> {
  Uint8List? _imageBytes;
  bool _loading = false;

  final supabase = Supabase.instance.client;

  // ================= PICK IMAGE =================
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  // ================= UPLOAD =================
  Future<void> _upload() async {
    if (_imageBytes == null) return;

    setState(() => _loading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final path = 'signature/$userId/signature.png';

      // upload ke Supabase
      await supabase.storage
          .from('TanonApp Storage')
          .uploadBinary(
            path,
            _imageBytes!,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/png',
            ),
          );

      // ambil public url
      final url =
          supabase.storage.from('TanonApp Storage').getPublicUrl(path);

      // simpan ke Firestore
      await UserController().updateUserSignature(
        userId: userId,
        signatureUrl: url,
      );

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload tanda tangan: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanda Tangan RT'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PREVIEW GAMBAR
            if (_imageBytes != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.memory(
                  _imageBytes!,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Text(
                'Pilih gambar tanda tangan',
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 24),

            // ================= BUTTON PILIH GAMBAR =================
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF245BCA),
                elevation: 0,
                side: const BorderSide(
                  color: Color(0xFF245BCA),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Pilih Gambar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ================= BUTTON SIMPAN =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
