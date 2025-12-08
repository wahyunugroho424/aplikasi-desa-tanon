class User {
  String id;
  String nik;
  String username;
  String email;
  String password;
  String birthPlaceDate; 
  String religion;
  String nationality;
  String occupation;
  String maritalStatus;
  String areaId;
  String phone;
  String role;

  User({
    required this.id,
    required this.nik,
    required this.username,
    required this.email,
    required this.password,
    required this.birthPlaceDate,
    required this.religion,
    required this.nationality,
    required this.occupation,
    required this.maritalStatus,
    required this.areaId,
    required this.phone,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nik: map['nik'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      birthPlaceDate: map['birthPlaceDate'] ?? '',
      religion: map['religion'] ?? '',
      nationality: map['nationality'] ?? '',
      occupation: map['occupation'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      areaId: map['areaId'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'username': username,
      'email': email,
      'password': password,
      'birthPlaceDate': birthPlaceDate,
      'religion': religion,
      'nationality': nationality,
      'occupation': occupation,
      'maritalStatus': maritalStatus,
      'areaId': areaId,
      'phone': phone,
      'role': role,
    };
  }
}