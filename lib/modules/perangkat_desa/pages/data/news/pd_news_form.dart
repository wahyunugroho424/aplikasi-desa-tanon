import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../../core/controllers/news_controller.dart';
import '../../../../../core/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DesaDataNewsFormPage extends StatefulWidget {
  final String? id;
  const DesaDataNewsFormPage({super.key, this.id});
  
  @override
  State<DesaDataNewsFormPage> createState() => _DesaDataNewsFormPageState();
}

class _DesaDataNewsFormPageState extends State<DesaDataNewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final authController = AuthController();
  String status = 'Draft';

  PlatformFile? thumbnailFile;
  List<PlatformFile> supportingFiles = [];

  final controller = NewsController();
  bool isLoading = true;
  bool get isEdit => widget.id != null;

  String? existingThumbnail;
  List<dynamic> existingFiles = [];

  @override
  void initState() {
    super.initState();
    if (isEdit) _load();
    else isLoading = false;
  }

  Future<void> _load() async {
    final news = await controller.getNewsById(widget.id!);
    if (news != null) {
      titleController.text = news.title;
      contentController.text = news.content;
      status = news.status;

      existingThumbnail = news.thumbnail;
      existingFiles = news.files;
    }
    setState(() => isLoading = false);
  }

  Future<void> _pickThumbnail() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => thumbnailFile = res.files.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum pilih thumbnail'))
      );
    }
  }

  Future<void> _pickSupportingFiles() async {
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() {
        supportingFiles.addAll(res.files);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEdit && thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih thumbnail terlebih dahulu'))
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final currentUser = authController.currentUser;
      String username = 'Admin';

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          username = userDoc.data()?['username'] ?? 'Admin';
        }
      }

      if (isEdit) {
        await controller.updateNews(
          id: widget.id!,
          title: titleController.text,
          content: contentController.text,
          userId: username,
          status: status,
          newPlatformThumbnail: thumbnailFile,
          newPlatformFiles: supportingFiles.isEmpty ? null : supportingFiles,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berita berhasil diperbarui'))
        );
      } else {
        await controller.addNews(
          title: titleController.text,
          content: contentController.text,
          userId: username,
          status: status,
          platformThumbnail: thumbnailFile,
          platformFiles: supportingFiles.isEmpty ? null : supportingFiles,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berita berhasil ditambahkan'))
        );
      }

      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'))
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEdit ? "Ubah Berita" : "Tambah Berita",
          style: GoogleFonts.poppins(
            color: const Color(0xFF00194A),
            fontWeight: FontWeight.w600
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Berita', border: OutlineInputBorder()
                ),
                validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Isi Berita', border: OutlineInputBorder()
                ),
                maxLines: 6,
                validator: (v) => v!.isEmpty ? 'Isi berita tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(
                  labelText: 'Status', border: OutlineInputBorder()
                ),
                items: const [
                  DropdownMenuItem(value: 'Draft', child: Text('Draft')),
                  DropdownMenuItem(value: 'Unpublish', child: Text('Unpublish')),
                  DropdownMenuItem(value: 'Publish', child: Text('Publish')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => status = v);
                },
              ),

              const SizedBox(height: 16),

              if (isEdit && existingThumbnail != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Thumbnail Lama",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        existingThumbnail!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              Text('Thumbnail',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickThumbnail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF245BCA),
                      side: const BorderSide(color: Color(0xFF245BCA), width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Pilih',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF245BCA),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: thumbnailFile?.name ?? 'Belum pilih thumbnail',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (isEdit && existingFiles.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("File Pendukung Lama",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    ...existingFiles.map((f) => Row(
                      children: [
                        const Icon(Icons.insert_drive_file, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            f['name'] ?? 'unknown',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )),

                    const SizedBox(height: 16),
                  ],
                ),

              Text('File Pendukung',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickSupportingFiles,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF245BCA),
                          side: const BorderSide(color: Color(0xFF245BCA), width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Pilih',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF245BCA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("${supportingFiles.length} file dipilih"),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (supportingFiles.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: supportingFiles
                          .map((f) => Chip(
                                label: Text(
                                  f.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                onPressed: _save,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                      isEdit ? 'Simpan Perubahan' : 'Simpan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}