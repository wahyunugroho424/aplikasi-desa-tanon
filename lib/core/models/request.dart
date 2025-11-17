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
  final String? serviceName;

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
    this.serviceName,
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

  Request copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? areaId,
    String? status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? notes,
    String? fileUrl,
    DateTime? createdAt,
    String? serviceName,
  }) {
    return Request(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      areaId: areaId ?? this.areaId,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      notes: notes ?? this.notes,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      serviceName: serviceName ?? this.serviceName,
    );
  }
}