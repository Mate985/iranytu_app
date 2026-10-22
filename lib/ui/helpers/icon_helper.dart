import 'package:flutter/material.dart';

class IconOption {
  final String key;
  final IconData icon;
  final String label;

  const IconOption({
    required this.key,
    required this.icon,
    required this.label,
  });
}

class AppIcons {
  // A szülői feladatkészítőben választható ikonok listája
  static const List<IconOption> availableIcons = [
    IconOption(key: 'bed', icon: Icons.bed_rounded, label: 'Ágy / Alvás'),
    IconOption(
      key: 'restaurant',
      icon: Icons.restaurant_rounded,
      label: 'Étkezés',
    ),
    IconOption(
      key: 'toothbrush',
      icon: Icons.clean_hands_rounded,
      label: 'Fogmosás',
    ),
    IconOption(
      key: 'checkroom',
      icon: Icons.checkroom_rounded,
      label: 'Fogas / Ruha',
    ),
    IconOption(
      key: 'door_front_door',
      icon: Icons.door_front_door_rounded,
      label: 'Ajtó / Indulás',
    ),
    IconOption(
      key: 'sports_esports',
      icon: Icons.sports_esports_rounded,
      label: 'Játék / Kontroller',
    ),
    IconOption(
      key: 'menu_book',
      icon: Icons.menu_book_rounded,
      label: 'Könyv / Lecke',
    ),
    IconOption(
      key: 'inventory_2',
      icon: Icons.inventory_2_rounded,
      label: 'Doboz / Elpakolás',
    ),
    IconOption(key: 'bathtub', icon: Icons.bathtub_rounded, label: 'Fürdőkád'),
  ];

  // Ez rendeli hozzá a nevekhez a képernyőn megjelenő rajzot:
  static IconData getIcon(String? iconPath) {
    switch (iconPath) {
      case 'bed':
        return Icons.bed_rounded; // Ágy
      case 'restaurant':
        return Icons.restaurant_rounded; // Villa és kés
      case 'toothbrush':
      case 'brush':
        return Icons
            .clean_hands_rounded; // Tisztálkodás / fogápolás (nem söprű!)
      case 'checkroom':
        return Icons.checkroom_rounded; // Fogas
      case 'door_front_door':
        return Icons.door_front_door_rounded; // Ajtó
      case 'sports_esports':
      case 'gamepad':
        return Icons.sports_esports_rounded; // Joystick / kontroller
      case 'menu_book':
        return Icons.menu_book_rounded; // Könyv
      case 'inventory_2':
        return Icons.inventory_2_rounded; // Játékos doboz
      case 'bathtub':
        return Icons.bathtub_rounded; // Fürdőkád
      default:
        return Icons.task_alt_rounded;
    }
  }
}
