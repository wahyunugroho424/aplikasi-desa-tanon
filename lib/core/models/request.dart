class Request {
  final String id;
  final String userId;
  final String serviceId;
  final String areaId;
  final String status;
  final String? serviceName;
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
    this.serviceName,
    this.verifiedBy,
    this.verifiedAt,
    this.notes,
    this.fileUrl,
    required this.createdAt,
  });

  /// 🔹 Konversi dari Map (Firebase Realtime Database) ke Object
  factory Request.fromMap(Map<String, dynamic> data, String id) {
    // Pastikan tanggal dibuat dengan nilai default jika null
    final parsedCreatedAt = data['createdAt'] != null
        ? DateTime.tryParse(data['createdAt'].toString())
        : DateTime.now();

    return Request(
      id: id,
      userId: data['userId'] ?? '',
      serviceId: data['serviceId'] ?? '',
      areaId: data['areaId'] ?? '',
      serviceName: data['serviceName'],
      status: data['status'] ?? '',
      verifiedBy: data['verifiedBy'],
      verifiedAt: data['verifiedAt'] != null
          ? DateTime.tryParse(data['verifiedAt'].toString())
          : null,
      notes: data['notes'] ?? '',
      fileUrl: data['fileUrl'],
      createdAt: parsedCreatedAt ?? DateTime.now(),
    );
  }

  /// 🔹 Konversi dari Object ke Map (untuk dikirim ke Firebase)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'serviceId': serviceId,
      'areaId': areaId,
      'serviceName': serviceName,
      'status': status,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'notes': notes,
      'fileUrl': fileUrl,
      // ❗ createdAt tidak nullable, jadi langsung dipanggil
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 🔹 Membuat salinan object dengan perubahan sebagian (copyWith)
  Request copyWith({
    String? id,
    String? userId,
    String? serviceId,
    String? serviceName,
    String? areaId,
    String? status,
    String? verifiedBy,
    DateTime? verifiedAt,
    String? notes,
    String? fileUrl,
    DateTime? createdAt,
  }) {
    return Request(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      areaId: areaId ?? this.areaId,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      notes: notes ?? this.notes,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}