class Carousel {
  String? id;
  String title;
  String discount;
  String image;
  String textColor;

  Carousel({
    this.id,
    required this.title,
    required this.image,
    required this.discount,
    this.textColor = 'FFFFFF',
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      id: json['id'] as String?,
      title: json['title'] as String,
      discount: json['discount'] as String,
      image: json['image'] as String,
      textColor: json['textColor'] as String? ?? 'FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title,
      'discount': discount,
      'image': image,
      'textColor': textColor,
    };
    return data;
  }
}