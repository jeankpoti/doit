import 'package:flutter/material.dart';
import '../features/pomodoro/presentation/pomodoro_setting_page.dart';

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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PomodoroSettingPage(),
                  ),
                ),
                icon: const Icon(Icons.settings),
              ),
              // IconButton(
              //   icon: const Icon(Icons.brightness_4),
              //   onPressed: () {
              //     context.read<ThemeCubit>().toggleTheme();
              //   },
              // ),
            ]
          : [],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Default app bar height
}
