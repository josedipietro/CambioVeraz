import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.text,
      required this.press,
      required this.color,
      required this.colorText,
      this.disabled = false,
      this.width = 200});
  final String? text;
  final Function press;
  final Color color;
  final Color colorText;
  final double width;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: OutlinedButton(
          style: OutlinedButton.styleFrom(
              backgroundColor: color, fixedSize: Size(width, 48)),
          onPressed: disabled ? null : press as void Function()?,
          child: Text(text!,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorText))),
    );
  }
}
