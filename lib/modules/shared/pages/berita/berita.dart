import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/controllers/news_controller.dart';
import '../../../../core/controllers/auth_controller.dart';
import '../../../../core/models/news.dart';

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});

  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  final NewsController _newsController = NewsController();
  final AuthController _authController = AuthController();
  final TextEditingController _searchController = TextEditingController();

  String _filter = 'Terbaru';
  late Stream<List<News>> _newsStream;

  @override
  void initState() {
    super.initState();
    _newsStream = _newsController.getPublishedNewsStream();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _newsStream = _newsController.getFilteredNewsStream(_searchController.text);
    });
  }

  void _applyFilter(String value) {
    setState(() {
      _filter = value;
      _newsStream = _newsController.getPublishedNewsStream();
      if (_filter == 'Terbaru') {
        _newsStream = _newsController.getPublishedNewsStream();
      } else if (_filter == 'Terlama') {
        _newsStream = _newsController.getPublishedNewsStream().map((list) {
          list.sort((a, b) {
            final aDate = a.publishedAt ?? DateTime(0);
            final bDate = b.publishedAt ?? DateTime(0);
            return aDate.compareTo(bDate);
          });
          return list;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 125,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_top.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Portal Berita Desa Tanon',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF00194A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Cari berita...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PopupMenuButton<String>(
                            icon: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4E82EA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.filter_list, color: Colors.white),
                            ),
                            onSelected: _applyFilter,
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'Terbaru', child: Text('Terbaru')),
                              PopupMenuItem(value: 'Terlama', child: Text('Terlama')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<List<News>>(
                stream: _newsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Belum ada berita."));
                  }

                  final beritaList = snapshot.data!;
                  return ListView.builder(
                    itemCount: beritaList.length,
                    itemBuilder: (context, index) {
                      final berita = beritaList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () => context.push(
                            '/${_authController.currentUserRole == 'Warga' ? 'wg' : 'pd'}/berita/detail',
                            extra: {
                              'newsId': berita.id,
                              'from': '/${_authController.getRoutePrefix()}/berita',
                            },
                          ),
                          child: _buildBeritaCard(context, berita),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeritaCard(BuildContext context, News berita) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  berita.thumbnail.isNotEmpty ? berita.thumbnail : 'https://via.placeholder.com/150',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00194A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    berita.publishedAt != null
                        ? '${berita.publishedAt!.day} ${_monthName(berita.publishedAt!.month)} ${berita.publishedAt!.year}, ${berita.publishedAt!.hour}:${berita.publishedAt!.minute.toString().padLeft(2, '0')}'
                        : '-',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Oleh: ${berita.userId}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
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

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month];
  }
}