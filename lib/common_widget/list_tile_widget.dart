import 'package:flutter/material.dart';

class ListTileWidget extends StatelessWidget {
  final String title;
  final String duration;
  final Future<void> Function() onPressed;
  const ListTileWidget({
    super.key,
    required this.title,
    required this.duration,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            duration,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
      ),
      onTap: () => onPressed(),
    );
  }
}
