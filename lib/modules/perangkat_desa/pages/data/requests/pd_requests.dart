import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/models/request.dart';
import '../../../../../core/models/user.dart';

class DesaDataRequestsPage extends StatefulWidget {
  const DesaDataRequestsPage({super.key});

  @override
  State<DesaDataRequestsPage> createState() => _DesaDataRequestsPageState();
}

class _DesaDataRequestsPageState extends State<DesaDataRequestsPage> {
  final requestController = RequestController();
  final userController = UserController();

  String searchKeyword = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<Request>>(
                stream: requestController.getRequestsStream(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<Request> list = snap.data!;

                  return StreamBuilder<List<User>>(
                    stream: userController.getUsersStream(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());

                      final users = {for (var u in userSnap.data!) u.id: u};

                      final filtered = list.where((req) {
                        final userName = users[req.userId]?.username ?? "-";
                        return userName.toLowerCase().contains(searchKeyword.toLowerCase());
                      }).toList();

                      return _buildRequestTable(filtered, users);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00194A)),
                onPressed: () => context.go('/pd/data'),
              ),
              const SizedBox(width: 8),
              Text(
                'Data Pengajuan',
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
            onChanged: (value) => setState(() => searchKeyword = value),
            decoration: InputDecoration(
              hintText: 'Cari berdasar nama pengaju',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTable(List<Request> list, Map<String, User> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(const Color(0xFFCEDDFF)),
        columns: const [
          DataColumn(label: Text("No")),
          DataColumn(label: Text("Tanggal")),
          DataColumn(label: Text("Layanan")),
          DataColumn(label: Text("Nama")),
          DataColumn(label: Text("Alamat")),
          DataColumn(label: Text("Status")),
          DataColumn(label: Text("Aksi")),
        ],
        rows: List.generate(list.length, (index) {
          final item = list[index];
          final user = users[item.userId];

          return DataRow(
            cells: [
              DataCell(Text("${index + 1}")),
              DataCell(Text(
                "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}",
              )),
              DataCell(
                FutureBuilder<String>(
                  future: requestController.getServiceName(item.serviceId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Text("-");
                    return Text(snapshot.data!);
                  },
                ),
              ),
              DataCell(Text(user?.username ?? "-")),
              DataCell(
                FutureBuilder<String>(
                  future: userController.getFullAddress(user?.areaId ?? ''),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("-");
                    }
                    return Text(snapshot.data!);
                  },
                ),
              ),
              DataCell(Text(item.status)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Color(0xFF245BCA)),
                      onPressed: () {
                        context.push('/pd/data/requests/detail', extra: {"id": item.id});
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}