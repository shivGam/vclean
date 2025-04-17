class Carousel {
  String title;
  String discount;
  String image;

  Carousel({
    required this.title,
    required this.image,
    required this.discount,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      title: json['title'] as String,
      discount: json['discount'] as String,
      image: json['image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'discount': discount,
      'image': image,
    };
  }
}