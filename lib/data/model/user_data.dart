class User {
  String userId;
  String name;
  String phone;
  String address;

  User({
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
  });

  User copyWith({
    String? userId,
    String? name,
    String? phone,
    String? address,
  }) {
    return User(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
    );
  }
}