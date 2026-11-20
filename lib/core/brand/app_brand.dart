import 'package:flutter/material.dart';

abstract final class AppBrand {
  static const name = 'Provida';
  static const tagline = 'Plan well. Live provided.';
  static const logoAsset = 'assets/branding/provida_logo.png';
}

class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppBrand.logoAsset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
