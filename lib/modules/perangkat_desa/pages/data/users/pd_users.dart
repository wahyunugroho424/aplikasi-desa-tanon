import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/models/user.dart';

class DesaDataUsersPage extends StatefulWidget {
  const DesaDataUsersPage({super.key});

  @override
  State<DesaDataUsersPage> createState() => _DesaDataUsersPageState();
}

class _DesaDataUsersPageState extends State<DesaDataUsersPage> {
  final controller = UserController();
  String searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data User',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00194A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        searchKeyword = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari berdasar username...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF00194A)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF00194A), width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: Color(0xFF00194A), width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<User>>(
                stream: searchKeyword.isEmpty
                    ? controller.getUsersStream()
                    : controller.getFilteredUsersStream(searchKeyword),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }
                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return const Center(child: Text('Data user belum tersedia'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final item = users[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildExpandableCard(context, user: item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/pd/data/users/add'),
        backgroundColor: const Color(0xFF245BCA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpandableCard(BuildContext context, {required User user}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCEDDFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00194A), width: 1.5),
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>(user.id),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('assets/images/list-users.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF00194A)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF245BCA)),
              onPressed: () => context.push('/pd/data/users/edit?id=${user.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFCA2424)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text('Yakin ingin menghapus data?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCA2424)),
                        child: const Text('Hapus', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await controller.deleteUser(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data pengguna berhasil dihapus')),
                  );
                }
              },
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text("Email:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Tempat, Tanggal Lahir:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.birthPlaceDate, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Agama:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.religion, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Kewarganegaraan:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.nationality, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Pekerjaan:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.occupation, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Status Pernikahan:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.maritalStatus, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Alamat:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          FutureBuilder<String>(
            future: controller.getFullAddress(user.areaId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('-', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]));
              }
              if (snapshot.hasError) {
                return Text('-', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]));
              }
              return Text(snapshot.data ?? '-', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]));
            },
          ),

          Text("No. Telepon:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.phone, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 4),

          Text("Role:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(user.role, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  String formatAddress(String rawAddress) {
    final parts = rawAddress.split(',').map((e) => e.trim()).toList();

    final rt = parts.isNotEmpty ? parts[0] : '-';
    final rw = parts.length > 1 ? parts[1] : '-';
    final dusun = parts.length > 2 ? parts[2] : '-';

    return 'RT $rt/RW $rw, Dsn. $dusun';
  }
}