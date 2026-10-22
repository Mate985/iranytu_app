import 'dart:io';
import 'package:flutter/material.dart';

class AppPicto extends StatelessWidget {
  final String? emoji;
  final String? assetPath;
  final String? filePath; // Később szülői feltöltéshez
  final IconData? fallbackIcon;
  final double size;
  final Color? color;

  const AppPicto({
    super.key,
    this.emoji,
    this.assetPath,
    this.filePath,
    this.fallbackIcon,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (filePath != null && filePath!.isNotEmpty) {
      final file = File(filePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.2),
          child: Image.file(file, width: size, height: size, fit: BoxFit.cover),
        );
      }
    }

    if (assetPath != null && assetPath!.isNotEmpty) {
      return Image.asset(
        assetPath!,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
    }

    if (emoji != null && emoji!.isNotEmpty) {
      return Text(
        emoji!,
        style: TextStyle(fontSize: size, height: 1.1),
        textAlign: TextAlign.center,
      );
    }

    return Icon(
      fallbackIcon ?? Icons.help_outline_rounded,
      size: size,
      color: color ?? const Color(0xFF334155),
    );
  }
}
