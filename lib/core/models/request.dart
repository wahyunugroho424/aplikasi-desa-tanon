class Request {
  final String id;
  final String userId;
  final String serviceId;
  final String areaId;
  final String status;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final String? notes;
  final String? fileUrl;
  final DateTime createdAt;

  Request({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.areaId,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
    this.fileUrl,
    required this.createdAt,
  });

  factory Request.fromMap(Map<String, dynamic> data, [String? id]) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return null;
    }

    return Request(
      id: id ?? data['id'] ?? '',
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      areaId: data['areaId'] ?? '',
      status: data['status'] ?? 'Diproses',
      verifiedBy: data['verifiedBy'],
      verifiedAt: parseDate(data['verifiedAt']),
      notes: data['notes'],
      fileUrl: data['fileUrl'],
      createdAt: parseDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'areaId': areaId,
      'status': status,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'notes': notes,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}