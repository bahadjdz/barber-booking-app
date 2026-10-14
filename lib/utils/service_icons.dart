import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceIconOption {
  final String key;
  final String label;
  final IconData icon;

  const ServiceIconOption({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class ServiceIcons {
  static const List<ServiceIconOption> options = [
    ServiceIconOption(
      key: 'scissors',
      label: 'مقص',
      icon: FontAwesomeIcons.scissors,
    ),
    ServiceIconOption(
      key: 'beard',
      label: 'حلاقة لحية',
      icon: SolarIconsOutline.userRounded,
    ),
    ServiceIconOption(
      key: 'smooth',
      label: 'تنعيم',
      icon: FontAwesomeIcons.wandMagicSparkles,
    ),
    ServiceIconOption(
      key: 'brush',
      label: 'برش',
      icon: FontAwesomeIcons.paintbrush,
    ),
    ServiceIconOption(
      key: 'style',
      label: 'ستايل',
      icon: SolarIconsOutline.crown,
    ),
    ServiceIconOption(
      key: 'color',
      label: 'تلوين',
      icon: SolarIconsOutline.palette,
    ),
    ServiceIconOption(
      key: 'care',
      label: 'عناية',
      icon: SolarIconsOutline.heart,
    ),
    ServiceIconOption(
      key: 'spray',
      label: 'رش/تثبيت',
      icon: SolarIconsOutline.bottle,
    ),
  ];

  static IconData getIcon(String key) {
    final match = options.where((o) => o.key == key);
    if (match.isNotEmpty) {
      return match.first.icon;
    }
    return FontAwesomeIcons.scissors;
  }
}
