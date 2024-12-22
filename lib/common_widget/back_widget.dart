import 'package:flutter/material.dart';

class BackWidget extends StatelessWidget {
  final Widget text;
  final Color? color;
  final Function() onPressed;

  const BackWidget({
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => onPressed(),
        child: text,
      ),
    );
  }
}
