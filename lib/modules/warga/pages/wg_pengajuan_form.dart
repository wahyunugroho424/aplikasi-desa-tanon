import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/controllers/user_controller.dart';

class WargaPengajuanFormPage extends StatefulWidget {
  const WargaPengajuanFormPage({super.key});

  @override
  State<WargaPengajuanFormPage> createState() => _WargaPengajuanFormPageState();
}

class _WargaPengajuanFormPageState extends State<WargaPengajuanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RequestController _requestController = RequestController();
  final UserController _userController = UserController();

  String? selectedServiceId;
  List<String> selectedRequirements = [];
  List<Map<String, dynamic>> services = [];

  String areaId = '';

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController birthPlaceDateController = TextEditingController();
  final TextEditingController religionController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController occupationController = TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadUserData();
  }

  Future<void> _loadServices() async {
    final snapshot = await _firestore.collection('services').get();
    setState(() {
      services = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'] ?? '-',
          'requirements': List<String>.from(doc['requirements'] ?? []),
        };
      }).toList();
    });
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return;

    final data = doc.data()!;
    areaId = data['areaId'] ?? '';

    // Ambil alamat lengkap dari areaId
    String fullAddress = '-';
    if (areaId.isNotEmpty) {
      fullAddress = await _userController.getFullAddress(areaId);
    }

    setState(() {
      usernameController.text = data['username'] ?? '';
      birthPlaceDateController.text = data['birthPlaceDate'] ?? '';
      religionController.text = data['religion'] ?? '';
      nationalityController.text = data['nationality'] ?? '';
      occupationController.text = data['occupation'] ?? '';
      maritalStatusController.text = data['maritalStatus'] ?? '';
      addressController.text = fullAddress;
      phoneController.text = data['phone'] ?? '';
    });
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih keperluan terlebih dahulu")),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _requestController.addRequest(
        userId: user.uid,
        serviceId: selectedServiceId!,
        areaId: areaId,
        notes: null,
      );

      if (!mounted) return;
      context.go('/wg/pengajuan/success');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat pengajuan: $e")),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    birthPlaceDateController.dispose();
    religionController.dispose();
    nationalityController.dispose();
    occupationController.dispose();
    maritalStatusController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
          onPressed: () => context.go('/wg/pengajuan'),
        ),
        title: Text(
          "Tambah Pengajuan",
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
              Text(
                "DATA KEPERLUAN",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00194A)),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedServiceId,
                decoration: const InputDecoration(
                  labelText: 'Keperluan',
                  border: OutlineInputBorder(),
                ),
                items: services.map<DropdownMenuItem<String>>((service) {
                  return DropdownMenuItem<String>(
                    value: service['id'],
                    child: Text(service['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedServiceId = value;
                    selectedRequirements = services
                        .firstWhere((s) => s['id'] == value)['requirements']
                        .cast<String>();
                  });
                },
              ),
              const SizedBox(height: 12),
              if (selectedRequirements.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PERSYARATAN YANG DIPERLUKAN:",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: const Color(0xFF00194A)),
                      ),
                      const SizedBox(height: 6),
                      ...selectedRequirements.map((req) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontSize: 12)),
                              Expanded(
                                child: Text(req,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey[700])),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                "DATA PRIBADI PENGAJU",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00194A)),
              ),
              const SizedBox(height: 8),
              _buildTextField(usernameController, 'Nama Lengkap'),
              const SizedBox(height: 10),
              _buildTextField(birthPlaceDateController, 'Tempat / Tanggal Lahir'),
              const SizedBox(height: 10),
              _buildTextField(religionController, 'Agama'),
              const SizedBox(height: 10),
              _buildTextField(nationalityController, 'Kewarganegaraan'),
              const SizedBox(height: 10),
              _buildTextField(occupationController, 'Pekerjaan'),
              const SizedBox(height: 10),
              _buildTextField(maritalStatusController, 'Status Perkawinan'),
              const SizedBox(height: 10),
              _buildTextField(addressController, 'Alamat'),
              const SizedBox(height: 10),
              _buildTextField(phoneController, 'Nomor Telepon'),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitRequest,
                child: Text(
                  'Buat Pengajuan',
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

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      validator: (value) =>
          (value == null || value.trim().isEmpty) ? 'Kolom ini wajib diisi' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}