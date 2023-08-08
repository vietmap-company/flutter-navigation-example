import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Svg extends StatelessWidget {
  final String svgName;
  final Color? color;
  final double? width;
  final double? height;
  final double? padding;
  const Svg(
    this.svgName, {
    super.key,
    this.color,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding ?? 0),
      child: SvgPicture.asset(
        'assets/svg/$svgName.svg',
        color: color,
        semanticsLabel: svgName,
        width: width,
        height: height,
      ),
    );
  }
}
