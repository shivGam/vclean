class LaundryService {
  String id;
  String name;
  String desc;
  String price;
  String rating;
  String period;

  LaundryService({
    required this.id,
    required this.name,
    required this.desc,
    required this.price,
    required this.rating,
    required this.period,
  });

  LaundryService copyWith({
    String? id,
    String? name,
    String? desc,
    String? image,
    String? price,
    String? rating,
    String? period,
  }) {
    return LaundryService(
      id: id ?? this.id,
      name: name ?? this.name,
      desc: desc ?? this.desc,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'name': name,
      'desc': desc,
      'price': price,
      'rating': rating,
      'period': period,
    };
  }

  factory LaundryService.fromJson(Map<String, dynamic> json) {
    return LaundryService(
      id: json['id'] as String,
      name: json['name'] as String,
      desc: json['desc'] as String,
      price: json['price'] as String,
      rating: json['rating'] as String,
      period: json['period'] as String,
    );
  }
}