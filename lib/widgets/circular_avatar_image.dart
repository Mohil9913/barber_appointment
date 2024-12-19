import 'package:flutter/material.dart';

class CircularAvatarImage extends StatelessWidget {
  const CircularAvatarImage({
    super.key,
    required this.image,
    required this.radius,
  });

  final String image;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.purpleAccent.withValues(alpha: 0.3),
          width: 5,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundImage: AssetImage(
          image,
        ),
      ),
    );
  }
}
