import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/controllers/request_controller.dart';
import '../../../../../core/controllers/user_controller.dart';
import '../../../../../core/controllers/area_controller.dart';
import '../../../../../core/models/request.dart';
import '../../../../../core/models/user.dart';
import '../../../../../core/models/area.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DesaDataRequestsPage extends StatefulWidget {
  const DesaDataRequestsPage({super.key});

  @override
  State<DesaDataRequestsPage> createState() => _DesaDataRequestsPageState();
}

class _DesaDataRequestsPageState extends State<DesaDataRequestsPage> {
  final requestController = RequestController();
  final userController = UserController();
  final areaController = AreaController();

  String searchKeyword = '';
  DateTime? startDate;
  DateTime? endDate;

  String? selectedHamletId;
  String? selectedRw;
  String? selectedRt;

  List<Map<String, dynamic>> hamletList = [];
  List<Map<String, dynamic>> rwList = [];
  List<Map<String, dynamic>> rtList = [];

  @override
  void initState() {
    super.initState();
    _loadHamlets();
  }

  Future<void> _loadHamlets() async {
    hamletList = await userController.getHamletList();
    setState(() {});
  }

  Future<void> _loadRwList(String hamletName) async {
    rwList = await userController.getRwList(hamletName);
    selectedRw = null;
    selectedRt = null;
    rtList = [];
    setState(() {});
  }

  Future<void> _loadRtList(String hamletName, String rw) async {
    rtList = await userController.getRtList(hamletName, rw);
    selectedRt = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: StreamBuilder<List<Request>>(
                        stream: requestController.getRequestsStream(),
                        builder: (context, snap) {
                          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                          final requests = snap.data!;

                          return StreamBuilder<List<User>>(
                            stream: userController.getUsersStream(),
                            builder: (context, userSnap) {
                              if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
                              final users = {for (var u in userSnap.data!) u.id: u};

                              return StreamBuilder<List<Area>>(
                                stream: areaController.getAreasStream(),
                                builder: (context, areaSnap) {
                                  if (!areaSnap.hasData) return const Center(child: CircularProgressIndicator());
                                  final areas = {for (var a in areaSnap.data!) a.id: a};

                                  final filtered = requests.where((req) {
                                    final user = users[req.userId];
                                    final area = areas[req.areaId];
                                    if (user == null || area == null) return false;

                                    final matchesKeyword = user.username.toLowerCase().contains(searchKeyword.toLowerCase());
                                    final matchesDate = (startDate == null || endDate == null) ||
                                        (req.createdAt.isAfter(startDate!.subtract(const Duration(days: 1))) &&
                                            req.createdAt.isBefore(endDate!.add(const Duration(days: 1))));
                                    final matchesHamlet = selectedHamletId == null || area.hamlet == selectedHamletId;
                                    final matchesRw = selectedRw == null || area.rw == selectedRw;
                                    final matchesRt = selectedRt == null || area.rt == selectedRt;

                                    return matchesKeyword && matchesDate && matchesHamlet && matchesRw && matchesRt;
                                  }).toList();

                                  return _buildRequestTable(filtered, users, areas);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () async {
                        final requests = await requestController.getRequestsStream().first;
                        final usersList = await userController.getUsersStream().first;
                        final areasList = await areaController.getAreasStream().first;
                        final users = {for (var u in usersList) u.id: u};
                        final areas = {for (var a in areasList) a.id: a};

                        final filtered = requests.where((req) {
                          final user = users[req.userId];
                          final area = areas[req.areaId];
                          if (user == null || area == null) return false;

                          final matchesKeyword = user.username.toLowerCase().contains(searchKeyword.toLowerCase());
                          final matchesDate = (startDate == null || endDate == null) ||
                              (req.createdAt.isAfter(startDate!.subtract(const Duration(days: 1))) &&
                                  req.createdAt.isBefore(endDate!.add(const Duration(days: 1))));
                          final matchesHamlet = selectedHamletId == null || area.hamlet == selectedHamletId;
                          final matchesRw = selectedRw == null || area.rw == selectedRw;
                          final matchesRt = selectedRt == null || area.rt == selectedRt;

                          return matchesKeyword && matchesDate && matchesHamlet && matchesRw && matchesRt;
                        }).toList();

                        _exportPdf(filtered, users, areas);
                      },
                      backgroundColor: const Color(0xFF245BCA),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final uniqueHamlets = hamletList.map((h) => h['hamlet']).toSet().toList();
    final uniqueRwList = rwList.map((r) => r['rw']).toSet().toList();
    final uniqueRtList = rtList.map((r) => r['rt']).toSet().toList();

    const borderColor = Color(0xFF245BCA);
    const textColor = Color(0xFF00194A);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: textColor),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                'Data Pengajuan',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          onChanged: (value) => setState(() => searchKeyword = value),
                          style: const TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Cari nama pengaju...',
                            hintStyle: const TextStyle(color: textColor),
                            prefixIcon: const Icon(Icons.search, color: borderColor),
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: borderColor, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                                initialDateRange: (startDate != null && endDate != null)
                                    ? DateTimeRange(start: startDate!, end: endDate!)
                                    : null,
                              );
                              if (picked != null) {
                                setState(() {
                                  startDate = picked.start;
                                  endDate = picked.end;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18, color: borderColor),
                            label: Text(
                              (startDate == null || endDate == null)
                                  ? "All"
                                  : "${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}",
                              style: const TextStyle(fontSize: 11, color: textColor),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: borderColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (startDate != null && endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20, color: borderColor),
                          onPressed: () => setState(() {
                            startDate = null;
                            endDate = null;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dusun", style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: selectedHamletId,
                              items: [
                                const DropdownMenuItem(value: null, child: Text("All")),
                                ...uniqueHamlets.map((h) => DropdownMenuItem<String>(
                                  value: h,
                                  child: Text(h, style: const TextStyle(color: Colors.black)),
                                )),
                              ],
                              onChanged: (value) async {
                                setState(() {
                                  selectedHamletId = value;
                                  selectedRw = null;
                                  selectedRt = null;
                                  rwList = [];
                                  rtList = [];
                                });
                                if (value != null) {
                                  await _loadRwList(value);
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor, width: 2),
                                ),
                                filled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("RW", style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: selectedRw,
                              items: [
                                const DropdownMenuItem(value: null, child: Text("All")),
                                ...uniqueRwList.map((rw) => DropdownMenuItem<String>(
                                  value: rw,
                                  child: Text(rw, style: const TextStyle(color: Colors.black)),
                                )),
                              ],
                              onChanged: (value) async {
                                setState(() {
                                  selectedRw = value;
                                  selectedRt = null;
                                  rtList = [];
                                });
                                if (value != null && selectedHamletId != null) {
                                  await _loadRtList(selectedHamletId!, value);
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor, width: 2),
                                ),
                                filled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("RT", style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
                            const SizedBox(height: 4),
                            DropdownButtonFormField<String>(
                              value: selectedRt,
                              items: [
                                const DropdownMenuItem(value: null, child: Text("All")),
                                ...uniqueRtList.map((rt) => DropdownMenuItem<String>(
                                  value: rt,
                                  child: Text(rt ?? '-', style: const TextStyle(color: textColor)),
                                )),
                              ],
                              onChanged: (value) => setState(() => selectedRt = value),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: borderColor, width: 2),
                                ),
                                filled: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestTable(List<Request> list, Map<String, User> users, Map<String, Area> areas) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'dibatalkan':
        case 'ditolak':
          return Colors.red;
        case 'diproses':
          return Colors.blue;
        case 'disetujui':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

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
          final area = areas[item.areaId];

          return DataRow(
            cells: [
              DataCell(Text("${index + 1}")),
              DataCell(Text("${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}")),
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
              DataCell(Text(area != null ? "RT ${area.rt}/RW ${area.rw} Dusun ${area.hamlet}" : "-")),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(item.status).withOpacity(0.2),
                    border: Border.all(color: getStatusColor(item.status)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(color: getStatusColor(item.status)),
                  ),
                ),
              ),
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

  Future<void> _exportPdf(List<Request> list, Map<String, User> users, Map<String, Area> areas) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            "Laporan Data Pengajuan",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ["No", "Tanggal", "Layanan", "Nama", "Alamat", "Status", "File"],
            data: List<List<String>>.generate(list.length, (index) {
              final item = list[index];
              final user = users[item.userId];
              final area = areas[item.areaId];
              return [
                "${index + 1}",
                "${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}",
                item.serviceName ?? "-",
                user?.username ?? "-",
                area != null ? "RT ${area.rt}/RW ${area.rw} Dusun ${area.hamlet}" : "-",
                item.status,
                item.fileUrl ?? "-",
              ];
            }),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}