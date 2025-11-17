import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/service_controller.dart';

class DesaDataServicesFormPage extends StatefulWidget {
  final String? id; 
  const DesaDataServicesFormPage({super.key, this.id});

  @override
  State<DesaDataServicesFormPage> createState() => _DesaDataServicesFormPageState();
}

class _DesaDataServicesFormPageState extends State<DesaDataServicesFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController requirementsController;
  late TextEditingController descriptionController;

  final controller = ServiceController();
  bool isLoading = true;

  bool get isEdit => widget.id != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    requirementsController = TextEditingController();
    descriptionController = TextEditingController();

    if (isEdit) _loadService();
    else isLoading = false;
  }

  Future<void> _loadService() async {
    final service = await controller.getServiceById(widget.id!);
    if (service != null) {
      nameController.text = service.name;
      descriptionController.text = service.description;
      requirementsController.text = service.requirements.join(', ');
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    requirementsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEdit) {
        await controller.updateService(
          id: widget.id!,
          name: nameController.text,
          description: descriptionController.text,
          requirementsRaw: requirementsController.text,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Keperluan berhasil diperbarui')));
      } else {
        await controller.addService(
          name: nameController.text,
          description: descriptionController.text,
          requirementsRaw: requirementsController.text,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Keperluan berhasil ditambahkan')));
      }

      context.go('/pd/data/services');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
          onPressed: () => context.go('/pd/data/services'),
        ),
        title: Text(
          isEdit ? "Ubah Keperluan" : "Tambah Keperluan",
          style: GoogleFonts.poppins(
            color: const Color(0xFF00194A),
            fontWeight: FontWeight.w600,
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
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Keperluan',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama Keperluan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: requirementsController,
                decoration: const InputDecoration(
                  labelText: 'Persyaratan (pisahkan dengan koma)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Persyaratan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _save,
                child: Text(
                  isEdit ? 'Simpan Perubahan' : 'Simpan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
