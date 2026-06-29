// CREADO POR: DANIEL INNOVA
import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.fallbackIcon = Icons.person,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade300,
        child: Icon(fallbackIcon, color: Colors.grey.shade700, size: radius),
      );
    }

    final fullUrl = imageUrl!.startsWith('http') ? imageUrl! : '${ApiConstants.baseUrl}$imageUrl';

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      backgroundImage: NetworkImage(fullUrl),
      onBackgroundImageError: (exception, stackTrace) {
        // El error queda silenciado por defecto,
        // pero podemos manejar un estado o log si se desea
      },
      child: Image.network(
        fullUrl,
        width: 0,
        height: 0,
        errorBuilder: (context, error, stackTrace) {
          // fallback visual
          return Icon(fallbackIcon, color: Colors.grey.shade700, size: radius);
        },
      ),
    );
  }
}
