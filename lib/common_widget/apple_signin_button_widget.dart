import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppleSigninButtonWidget extends StatelessWidget {
  final Widget text;
  final Color? color;
  final Function() onPressed;

  const AppleSigninButtonWidget({
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
        icon: FaIcon(
          FontAwesomeIcons.apple,
          size: 25,
          color: Theme.of(context)
              .colorScheme
              .secondary, // This color will be used as a mask
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
