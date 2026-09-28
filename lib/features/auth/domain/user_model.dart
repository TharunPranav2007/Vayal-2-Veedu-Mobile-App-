enum UserRole {
  FARMER,
  CONSUMER,
  DELIVERY_PARTNER,
  ADMIN,
}

UserRole userRoleFromString(String roleStr) {
  switch (roleStr.toUpperCase()) {
    case 'FARMER':
      return UserRole.FARMER;
    case 'CONSUMER':
      return UserRole.CONSUMER;
    case 'DELIVERY_PARTNER':
      return UserRole.DELIVERY_PARTNER;
    case 'ADMIN':
      return UserRole.ADMIN;
    default:
      return UserRole.CONSUMER;
  }
}

String userRoleToString(UserRole role) {
  return role.name;
}

class User {
  final String id;
  final String email;
  final String phone;
  final String name;
  final UserRole role;
  final String? profileImageUrl;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.role,
    this.profileImageUrl,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? 'User',
      role: userRoleFromString(json['role'] as String? ?? 'CONSUMER'),
      profileImageUrl: json['profileImageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'role': userRoleToString(role),
      'profileImageUrl': profileImageUrl,
      'isActive': isActive,
    };
  }
}
