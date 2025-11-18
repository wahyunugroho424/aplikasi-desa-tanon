import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/controllers/news_controller.dart';
import '../../../../core/models/news.dart';
import 'package:go_router/go_router.dart';

class BeritaDetailPage extends StatefulWidget {
  final String newsId; 
  const BeritaDetailPage({super.key, required this.newsId});

  @override
  State<BeritaDetailPage> createState() => _BeritaDetailPageState();
}

class _BeritaDetailPageState extends State<BeritaDetailPage> {
  News? news;
  final NewsController _newsController = NewsController();

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    final fetched = await _newsController.getNewsById(widget.newsId);
    setState(() {
      news = fetched;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (news == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(color: const Color(0xFFF2F6FF)),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: news!.thumbnail.isNotEmpty
                ? Image.network(news!.thumbnail, fit: BoxFit.cover)
                : Image.asset('assets/images/berita.png', fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF245BCA)),
                  onPressed: () { context.pop(); },
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        news!.title,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00194A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            news!.publishedAt != null
                                ? '${news!.publishedAt!.day} ${_monthName(news!.publishedAt!.month)} ${news!.publishedAt!.year}, ${news!.publishedAt!.hour}:${news!.publishedAt!.minute.toString().padLeft(2, '0')}'
                                : '-',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.person,
                              size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(news!.userId,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[700],
                              )),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        news!.content,
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: 
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (news!.files.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tidak ada file untuk diunduh')),
                                );
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Mengunduh file media...')),
                              );

                              try {
                                await _newsController.downloadNewsFiles(news!.files);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Download selesai!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal download: $e')),
                                );
                              }
                            },
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: Text(
                              'Unduh File Media',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF245BCA),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 5,
                            ),
                          ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
