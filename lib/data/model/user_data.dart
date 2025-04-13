class UserData {
  String userId;
  String name;
  String phone;
  String address;
  String photoUrl;

  UserData({
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    required this.photoUrl,
  });

  UserData copyWith({
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? photoUrl,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      userId: json['userId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }
}
