import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/controllers/auth_controller.dart';

class DesaDataUsersFormPage extends StatefulWidget {
  final String? id;
  const DesaDataUsersFormPage({super.key, this.id});

  @override
  State<DesaDataUsersFormPage> createState() => _DesaDataUsersFormPageState();
}

class _DesaDataUsersFormPageState extends State<DesaDataUsersFormPage> {
  final _formKey = GlobalKey<FormState>();
  final controller = UserController();
  final authController = AuthController();

  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  String? selectedRole;

  bool get isEdit => widget.id != null;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    if (isEdit) _loadUser();
    else isLoading = false;
  }

  Future<void> _loadUser() async {
    final user = await controller.getUserById(widget.id!);
    if (user != null) {
      usernameController.text = user.username;
      emailController.text = user.email;
      selectedRole = user.role.isNotEmpty ? user.role : null;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isEdit) {
        await controller.updateUserPartial(
          id: widget.id!,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text.isEmpty
              ? 'default123'
              : passwordController.text,
          role: selectedRole!,
        );
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('User berhasil diperbarui')));
        context.go('/pd/data/users');
      } else {
        final password = passwordController.text.isEmpty
            ? 'default123'
            : passwordController.text;

        final error = await authController.register(
          username: usernameController.text,
          email: emailController.text,
          password: password,
        );

        if (error != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $error')));
        } else {
          await controller.addUser(
            username: usernameController.text,
            email: emailController.text,
            password: password,
            role: selectedRole!,
          );

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User berhasil ditambahkan! Cek email untuk verifikasi.'),
          ));

          context.go('/pd/data/users');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
          onPressed: () => context.go('/pd/data/users'),
        ),
        title: Text(
          isEdit ? "Ubah User" : "Tambah User",
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
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!isEdit) ...[
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['Perangkat Desa','Warga','RT']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => selectedRole = value),
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Role harus dipilih' : null,
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