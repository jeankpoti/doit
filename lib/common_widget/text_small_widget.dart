import 'package:flutter/material.dart';

class TextSmallWidget extends StatelessWidget {
  final String text;
  final int? maxLine;
  const TextSmallWidget({super.key, required this.text, this.maxLine});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
      maxLines: maxLine,
    );
  }
}
