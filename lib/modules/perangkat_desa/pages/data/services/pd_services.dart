import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/service_controller.dart';
import '../../../../../core/models/service.dart';

class DesaDataServicesPage extends StatefulWidget {
  const DesaDataServicesPage({super.key});

  @override
  State<DesaDataServicesPage> createState() => _DesaDataServicesPageState();
}

class _DesaDataServicesPageState extends State<DesaDataServicesPage> {
  final controller = ServiceController();
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
                        'Data Keperluan',
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
                      hintText: 'Cari berdasar nama keperluan...',
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
              child: StreamBuilder<List<Service>>(
                stream: searchKeyword.isEmpty
                    ? controller.getServicesStream()
                    : controller.getFilteredServicesStream(searchKeyword),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }
                  final services = snapshot.data ?? [];

                  if (services.isEmpty) {
                    return const Center(child: Text('Data keperluan belum tersedia'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final item = services[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildExpandableCard(context, service: item),
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
        onPressed: () => context.push('/pd/data/services/add'),
        backgroundColor: const Color(0xFF245BCA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpandableCard(BuildContext context, {required Service service}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFCEDDFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00194A), width: 1.5),
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>(service.id),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: AssetImage('assets/images/list_services.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          service.name,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF00194A)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF245BCA)),
              onPressed: () => context.push('/pd/data/services/edit?id=${service.id}'),
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
                  await controller.deleteService(service.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data keperluan berhasil dihapus')),
                  );
                }
              },
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Text("Deskripsi:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          Text(service.description,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text("Persyaratan:",
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF00194A))),
          const SizedBox(height: 4),
          ...service.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: Color(0xFF00194A)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(req,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[800])),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
