import 'package:flutter/material.dart';

class FieldScholarship {
  final String title;
  final String count;
  final IconData icon;

  FieldScholarship({
    required this.title,
    required this.count,
    required this.icon,
  });
}

final List<FieldScholarship> scholarships = [
  FieldScholarship(
    title: 'Computer Science',
    count: '120+ scholarships',
    icon: Icons.desktop_windows,
  ),
  FieldScholarship(
    title: 'Engineering',
    count: '95+ scholarships',
    icon: Icons.memory,
  ),
  FieldScholarship(
    title: 'Medicine',
    count: '80+ scholarships',
    icon: Icons.medical_services_outlined,
  ),
  FieldScholarship(
    title: 'Business',
    count: '110+ scholarships',
    icon: Icons.business_center_outlined,
  ),
  FieldScholarship(title: 'Law', count: '60+ scholarships', icon: Icons.gavel),
  FieldScholarship(
    title: 'Natural Sciences',
    count: '75+ scholarships',
    icon: Icons.science_outlined,
  ),
  FieldScholarship(
    title: 'International Relations',
    count: '45+ scholarships',
    icon: Icons.language,
  ),
  FieldScholarship(
    title: 'Mathematics',
    count: '55+ scholarships',
    icon: Icons.calculate_outlined,
  ),
];
