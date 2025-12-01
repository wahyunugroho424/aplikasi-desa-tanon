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
  Map<String, dynamic> userData = {
    "username": "",
    "birthPlaceDate": "",
    "religion": "",
    "nationality": "",
    "occupation": "",
    "maritalStatus": "",
    "address": "",
    "phone": "",
  };

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

    String fullAddress = '-';
    if (areaId.isNotEmpty) {
      fullAddress = await _userController.getFullAddress(areaId);
    }

    setState(() {
      userData = {
        "username": data['username'] ?? '',
        "birthPlaceDate": data['birthPlaceDate'] ?? '',
        "religion": data['religion'] ?? '',
        "nationality": data['nationality'] ?? '',
        "occupation": data['occupation'] ?? '',
        "maritalStatus": data['maritalStatus'] ?? '',
        "address": fullAddress,
        "phone": data['phone'] ?? '',
      };
    });
  }

  Future<void> _confirmBeforeSubmit() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Pengajuan"),
          content: const Text("Apakah Anda yakin ingin membuat pengajuan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitRequest();
              },
              child: const Text("Ya, Lanjutkan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRequest() async {
    if (userData.values.any((v) => v.toString().isEmpty)) {
      _showIncompleteProfileDialog();
      return;
    }

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
      context.push('/wg/pengajuan/success');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat pengajuan: $e")),
      );
    }
  }

  void _showIncompleteProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Profil Belum Lengkap"),
          content: const Text("Silakan lengkapi profil terlebih dahulu sebelum membuat pengajuan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/wg/akun/profil').then((_) {
                  _loadUserData();
                });
              },
              child: const Text("Lengkapi Profil"),
            ),
          ],
        );
      },
    );
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
          onPressed: () => context.pop(),
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
                items: services.map((service) {
                  return DropdownMenuItem<String>(
                    value: service['id'],
                    child: Text(service['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedServiceId = value;
                    selectedRequirements =
                        services.firstWhere((s) => s['id'] == value)['requirements'];
                  });
                },
              ),
              const SizedBox(height: 12),
              if (selectedRequirements.isNotEmpty) _buildRequirementsBox(),
              const SizedBox(height: 20),
              Text(
                "DATA PRIBADI PENGAJU",
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00194A)),
              ),
              const SizedBox(height: 8),
              _buildProfileDisplay(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF245BCA),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _confirmBeforeSubmit,
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

  Widget _buildRequirementsBox() {
    return Container(
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
                    child: Text(
                      req,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildProfileDisplay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _infoRow("Nama Lengkap", userData["username"]),
          _infoRow("Tempat / Tanggal Lahir", userData["birthPlaceDate"]),
          _infoRow("Agama", userData["religion"]),
          _infoRow("Kewarganegaraan", userData["nationality"]),
          _infoRow("Pekerjaan", userData["occupation"]),
          _infoRow("Status Perkawinan", userData["maritalStatus"]),
          _infoRow("Alamat", userData["address"]),
          _infoRow("Nomor Telepon", userData["phone"]),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF00194A),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "-" : value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }
}