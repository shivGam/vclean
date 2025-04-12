class LaundryService {
  String name;
  String desc;
  String image;
  String price;
  String rating;
  String period;

  LaundryService({
    required this.name,
    required this.desc,
    required this.image,
    required this.price,
    required this.rating,
    required this.period,
  });

  LaundryService copyWith({
    String? name,
    String? desc,
    String? image,
    String? price,
    String? rating,
    String? period,
  }) {
    return LaundryService(
      name: name ?? this.name,
      desc: desc ?? this.desc,
      image: image ?? this.image,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      period: period ?? this.period,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'image': image,
      'price': price,
      'rating': rating,
      'period': period,
    };
  }

  factory LaundryService.fromJson(Map<String, dynamic> json) {
    return LaundryService(
      name: json['name'] as String,
      desc: json['desc'] as String,
      image: json['image'] as String,
      price: json['price'] as String,
      rating: json['rating'] as String,
      period: json['period'] as String,
    );
  }
}