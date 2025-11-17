class Area {
  String id;
  String rt;
  String rw;
  String hamlet;
  String userId;

  Area({
    required this.id,
    required this.rt,
    required this.rw,
    required this.hamlet,
    required this.userId,
  });

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'],
      rt: map['rt'],
      rw: map['rw'],
      hamlet: map['hamlet'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rt': rt,
      'rw': rw,
      'hamlet': hamlet,
      'userId': userId,
    };
  }
}
