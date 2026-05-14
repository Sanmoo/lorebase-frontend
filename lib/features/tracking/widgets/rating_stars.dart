// coverage:ignore-file
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int? rating;
  final int maxRating;
  final double size;
  final ValueChanged<int>? onRatingChanged;

  const RatingStars({
    super.key,
    this.rating,
    this.maxRating = 10,
    this.size = 24,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFilled = rating != null && starValue <= rating!;
        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starValue) : null,
          child: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: isFilled ? Colors.amber : Colors.grey,
            size: size,
          ),
        );
      }),
    );
  }
}
