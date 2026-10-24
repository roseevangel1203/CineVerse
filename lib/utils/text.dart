import 'package:flutter/material.dart';

class ModifiedText extends StatelessWidget {
  final String? text;
  final Color? color;
  final double? size;

  const ModifiedText({
    super.key,
    this.text,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
  }
}
