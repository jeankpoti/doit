import 'package:flutter/material.dart';

class ElevatedButtonIconWidget extends StatelessWidget {
  final String text;
  final Widget icon;
  final Function() onPressed;
  const ElevatedButtonIconWidget({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => onPressed(),
      icon: icon,
      label: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
