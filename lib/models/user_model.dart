class UserModel {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // Admin, Driver, Parent

  UserModel({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'Parent',
    );
  }
}
