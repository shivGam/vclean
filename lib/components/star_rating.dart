import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;
  final Function(double)? onRatingChanged;

  const StarRating({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.color = Colors.amber,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            if (onRatingChanged != null) {
              onRatingChanged!(index + 1.0);
            }
          },
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}