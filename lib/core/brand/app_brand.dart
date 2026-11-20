import 'package:flutter/material.dart';

abstract final class AppBrand {
  static const name = 'Provida';
  static const tagline = 'Plan well. Live provided.';
}

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF7659EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_rounded, color: Colors.white.withOpacity(0.18), size: size * 0.68),
          Text(
            'P',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.46,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -2,
            ),
          ),
          Positioned(
            right: size * 0.18,
            top: size * 0.2,
            child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * 0.18),
          ),
        ],
      ),
    );
  }
}
