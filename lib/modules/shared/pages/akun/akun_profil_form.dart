import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/user_controller.dart';
import 'package:flutter/services.dart';

class AkunProfilFormPage extends StatefulWidget {
  final String routePrefix;
  const AkunProfilFormPage({super.key, required this.routePrefix});

  @override
  State<AkunProfilFormPage> createState() => _AkunProfilFormPageState();
}

class _AkunProfilFormPageState extends State<AkunProfilFormPage> {
  final _formKey = GlobalKey<FormState>();
  final userController = UserController();

  late TextEditingController nikController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController birthPlaceController;
  late TextEditingController birthDateController;
  late TextEditingController phoneController;
  late TextEditingController occupationController;

  String? selectedReligion;
  String? selectedNationality;
  String? selectedMaritalStatus;
  String? selectedRole;

  String? selectedHamletId;
  String? selectedRt;
  String? selectedRw;

  bool isLoading = true;
  String? userId;
  List<Map<String, dynamic>> hamletList = [];
  List<Map<String, dynamic>> rtList = [];
  List<Map<String, dynamic>> rwList = [];

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    birthPlaceController = TextEditingController();
    birthDateController = TextEditingController();
    phoneController = TextEditingController();
    occupationController = TextEditingController();

    _loadUser();
    _loadhamletList();
  }

  Future<void> _loadhamletList() async {
    hamletList = await userController.getHamletList();
    setState(() {});
  }

  Future<void> _loadUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() => isLoading = false);
      return;
    }
    userId = currentUser.uid;

    final user = await userController.getUserById(userId!);
    if (user != null) {
      nikController.text = user.nik;
      usernameController.text = user.username;
      emailController.text = user.email;
      passwordController.text = user.password;

      if (user.birthPlaceDate.isNotEmpty && user.birthPlaceDate.contains(',')) {
        final parts = user.birthPlaceDate.split(',');
        birthPlaceController.text = parts[0].trim();
        birthDateController.text = parts[1].trim();
      }

      selectedReligion = user.religion.isNotEmpty ? user.religion : null;
      selectedNationality = user.nationality.isNotEmpty ? user.nationality : null;
      selectedMaritalStatus = user.maritalStatus.isNotEmpty ? user.maritalStatus : null;
      selectedRole = user.role.isNotEmpty ? user.role : null;
      occupationController.text = user.occupation;
      phoneController.text = user.phone;

      if (user.areaId.isNotEmpty) {
        final areaList = await userController.getHamletList();
        final areaDoc = areaList.firstWhere(
          (a) => a['id'] == user.areaId,
          orElse: () => {},
        );

        if (areaDoc.isNotEmpty) {
          selectedHamletId = areaDoc['id'];
          selectedRt = areaDoc['rt'];
          selectedRw = areaDoc['rw'];
        }

        if (selectedHamletId != null) {
          final hamletName = hamletList.firstWhere((e) => e['id'] == selectedHamletId)['hamlet'];
          rwList = await userController.getRwList(hamletName);
        }

        if (selectedRw != null && selectedHamletId != null) {
          final hamletName = hamletList.firstWhere((e) => e['id'] == selectedHamletId)['hamlet'];
          rtList = await userController.getRtList(hamletName, selectedRw!);
        }
      }
    }
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    nikController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    birthPlaceController.dispose();
    birthDateController.dispose();
    phoneController.dispose();
    occupationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      String areaId = '';
      if (selectedHamletId != null && selectedRt != null && selectedRw != null) {
        final match = rwList.firstWhere(
          (e) => e['rw'] == selectedRw && e['rt'] == selectedRt,
          orElse: () => {},
        );
        areaId = match['id'] ?? '';
      }

      await userController.updateUser(
        id: userId!,
        nik: nikController.text,
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        birthPlace: birthPlaceController.text,
        birthDate: birthDateController.text,
        religion: selectedReligion!,
        nationality: selectedNationality!,
        occupation: occupationController.text,
        maritalStatus: selectedMaritalStatus!,
        areaId: areaId,
        phone: phoneController.text,
        role: selectedRole!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF245BCA)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Ubah Profil",
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
                controller: nikController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                decoration: const InputDecoration(
                  labelText: 'NIK',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK tidak boleh kosong';
                  }
                  if (value.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField('Username', usernameController),
              const SizedBox(height: 16),
              _buildTextField('Email', emailController, enabled: false),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Tempat Lahir', birthPlaceController)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: birthDateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          birthDateController.text =
                              "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                        }
                      },
                      validator: (value) =>
                          value!.isEmpty ? 'Tanggal lahir tidak boleh kosong' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                'Agama',
                selectedReligion,
                ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'],
                (v) => setState(() => selectedReligion = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      'Kewarganegaraan',
                      selectedNationality,
                      ['WNI', 'WNA'],
                      (v) => setState(() => selectedNationality = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDropdown(
                      'Status Pernikahan',
                      selectedMaritalStatus,
                      ['Lajang', 'Menikah', 'Duda', 'Janda'],
                      (v) => setState(() => selectedMaritalStatus = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Pekerjaan', occupationController, required: false),
              const SizedBox(height: 16),
              _buildTextField('No. HP', phoneController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildHamletDropdown()),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: _buildRwDropdown()),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: _buildRtDropdown()),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = true,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator ??
          (value) =>
              required && value!.isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null ? '$label harus dipilih' : null,
    );
  }

  Widget _buildHamletDropdown() {
    final hamletNames = hamletList.map((e) => e['hamlet'] ?? '-').toSet().toList();

    return DropdownButtonFormField<String>(
      value: selectedHamletId != null
          ? hamletList.firstWhere((e) => e['id'] == selectedHamletId)['hamlet']
          : null,
      items: hamletNames
          .map((hamlet) => DropdownMenuItem<String>(
                value: hamlet,
                child: Text(hamlet),
              ))
          .toList(),
      onChanged: (v) async {
        final hamletName = v;
        setState(() {
          selectedHamletId =
              hamletList.firstWhere((e) => e['hamlet'] == hamletName)['id'];
          selectedRw = null;
          selectedRt = null;
          rwList = [];
          rtList = [];
        });
        if (hamletName != null) {
          rwList = await userController.getRwList(hamletName);
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: 'Dusun',
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null ? 'Dusun harus dipilih' : null,
    );
  }

  Widget _buildRwDropdown() {
    final rwNames = rwList.map((e) => e['rw'] ?? '-').toSet().toList();

    return DropdownButtonFormField<String>(
      value: selectedRw,
      items: rwNames
          .map((rw) => DropdownMenuItem<String>(
                value: rw,
                child: Text(rw),
              ))
          .toList(),
      onChanged: selectedHamletId == null ? null : (v) async {
        setState(() {
          selectedRw = v;
          selectedRt = null;
          rtList = [];
        });
        if (v != null && selectedHamletId != null) {
          final hamletName = hamletList.firstWhere((e) => e['id'] == selectedHamletId)['hamlet'];
          rtList = await userController.getRtList(hamletName, v);
          setState(() {});
        }
      },
      decoration: InputDecoration(
        labelText: 'RW',
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null ? 'RW harus dipilih' : null,
    );
  }

  Widget _buildRtDropdown() {
    final rtNames = rtList.map((e) => e['rt'] ?? '-').toSet().toList();

    return DropdownButtonFormField<String>(
      value: selectedRt,
      items: rtNames
          .map((rt) => DropdownMenuItem<String>(
                value: rt,
                child: Text(rt),
              ))
          .toList(),
      onChanged: rtList.isEmpty ? null : (v) {
        setState(() {
          selectedRt = v;
        });
      },
      decoration: InputDecoration(
        labelText: 'RT',
        border: const OutlineInputBorder(),
      ),
      validator: (v) => v == null ? 'RT harus dipilih' : null,
    );
  }
}