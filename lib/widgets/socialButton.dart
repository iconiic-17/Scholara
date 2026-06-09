import 'package:flutter/material.dart';

Widget socialButton(IconData icon) {
  return SizedBox(
    width: 75,
    height: 60,
    child: IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 70, color: Colors.amber),
    ),
  );
}
