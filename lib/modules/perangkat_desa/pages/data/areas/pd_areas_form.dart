import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/area_controller.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/models/user.dart';

class DesaDataAreasFormPage extends StatefulWidget {
  final String? id;
  const DesaDataAreasFormPage({super.key, this.id});

  @override
  State<DesaDataAreasFormPage> createState() => _DesaDataAreasFormPageState();
}

class _DesaDataAreasFormPageState extends State<DesaDataAreasFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController rtController;
  late TextEditingController rwController;
  late TextEditingController hamletController;

  final areaController = AreaController();
  final userController = UserController();

  bool isLoading = true;
  bool get isEdit => widget.id != null;

  List<User> usersRT = [];
  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    rtController = TextEditingController();
    rwController = TextEditingController();
    hamletController = TextEditingController();
    _loadUsersRT();
    if (isEdit) {
      _loadArea();
    } else {
      isLoading = false;
    }
  }

  Future<void> _loadUsersRT() async {
    usersRT = await userController.getUsersByRole("RT");
    setState(() {});
  }

  Future<void> _loadArea() async {
    final area = await areaController.getAreaById(widget.id!);
    if (area != null) {
      rtController.text = area.rt;
      rwController.text = area.rw;
      hamletController.text = area.hamlet;
      selectedUserId = area.userId;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    rtController.dispose();
    rwController.dispose();
    hamletController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEdit) {
        await areaController.updateArea(
          id: widget.id!,
          rt: rtController.text,
          rw: rwController.text,
          hamlet: hamletController.text,
          userId: selectedUserId!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Data area berhasil diperbarui')));
      } else {
        await areaController.addArea(
          rt: rtController.text,
          rw: rwController.text,
          hamlet: hamletController.text,
          userId: selectedUserId!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Data area berhasil ditambahkan')));
      }

      context.go('/pd/data/areas');
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
          onPressed: () => context.go('/pd/data/areas'),
        ),
        title: Text(
          isEdit ? "Ubah Data Area" : "Tambah Data Area",
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
                controller: rtController,
                decoration: const InputDecoration(
                  labelText: 'RT',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'RT tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: rwController,
                decoration: const InputDecoration(
                  labelText: 'RW',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'RW tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: hamletController,
                decoration: const InputDecoration(
                  labelText: 'Dusun',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Dusun tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Pilih Ketua RT',
                  border: OutlineInputBorder(),
                ),
                value: selectedUserId,
                items: usersRT.map((user) {
                  return DropdownMenuItem<String>(
                    value: user.id,
                    child: Text(user.username),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedUserId = value),
                validator: (value) =>
                    value == null ? 'Pilih salah satu RT' : null,
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
