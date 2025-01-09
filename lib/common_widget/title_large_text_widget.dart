import 'package:flutter/material.dart';

class TitleLargeTextWidget extends StatelessWidget {
  final String text;
  const TitleLargeTextWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
