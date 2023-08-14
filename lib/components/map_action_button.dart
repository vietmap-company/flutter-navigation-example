import 'package:flutter/material.dart';

import '../constants/colors.dart';

class MapActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const MapActionButton(
      {super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ))),
        child: child);
  }
}

class MapActionButtonOutline extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  const MapActionButtonOutline(
      {super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
            backgroundColor: const MaterialStatePropertyAll(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: const BorderSide(color: vietmapColor)))),
        child: child);
  }
}
