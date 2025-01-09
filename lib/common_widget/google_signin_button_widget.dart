import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GoogleSigninButtonWidget extends StatelessWidget {
  final Widget text;
  final Color? color;
  final Function() onPressed;

  const GoogleSigninButtonWidget({
    super.key,
    required this.text,
    this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 375,
      child: ElevatedButton.icon(
        icon: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Colors.red,
              Colors.yellow,
              Colors.green,
              Colors.blue
            ], // Replace with your desired colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const FaIcon(
            FontAwesomeIcons.google,
            size: 25,
            color: Colors.white, // This color will be used as a mask
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => onPressed(),
        label: text,
      ),
    );
  }
}
