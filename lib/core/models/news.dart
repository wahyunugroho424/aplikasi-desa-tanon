class News {
  final String id;
  final String title;
  final String thumbnail;
  final String content;
  final String userId;
  final String status;
  final List<Map<String, dynamic>> files;
  final DateTime? publishedAt;

  News({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.content,
    required this.userId,
    required this.status,
    required this.files,
    this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'thumbnail': thumbnail,
      'content': content,
      'userId': userId,
      'status': status,
      'files': files,
      'publishedAt': publishedAt?.toIso8601String(),
    };
  }

  factory News.fromMap(Map<dynamic, dynamic> map, String id) {
    return News(
      id: id,
      title: map['title'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      content: map['content'] ?? '',
      userId: map['userId'] ?? '',
      status: map['status'] ?? 'draft',
      files: (map['files'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      publishedAt: map['publishedAt'] != null
          ? DateTime.tryParse(map['publishedAt'])
          : null,
    );
  }
}
