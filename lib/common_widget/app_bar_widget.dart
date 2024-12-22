import 'package:do_it/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final bool? isAction;
  final String title;
  const AppBarWidget({super.key, required this.title, this.isAction = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      actions: isAction == true
          ? [
              IconButton(
                icon: const Icon(Icons.brightness_4),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ]
          : [],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default app bar height
}
