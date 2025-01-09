import 'package:do_it/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common_widget/app_bar_widget.dart';
import 'common_widget/settings_list_tile.dart';
import 'features/account/presentation/sign_in_page.dart';
import 'features/todo/presentation/completed_todo_page.dart';

class SetingsPage extends StatefulWidget {
  const SetingsPage({super.key});

  @override
  State<SetingsPage> createState() => _SetingsPageState();
}

class _SetingsPageState extends State<SetingsPage> {
  bool _isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Settings',
        isAction: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SettingsListTile(
                text: 'Change theme',
                icon: Icon(
                  Icons.brightness_4,
                  color: Theme.of(context).colorScheme.primary,
                ),
                switcher: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                      // Add your theme change logic here
                      context.read<ThemeCubit>().toggleTheme();
                    });
                  },
                ),
              ),
              SettingsListTile(
                text: 'Historics',
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompletedTodoPage(),
                  ),
                ),
              ),

              SettingsListTile(
                text: 'Sign in to Sync data',
                icon: Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInPage(),
                  ),
                ),
              ),
              // SettingsListTile(
              //   text: 'Configure pomodoro ',
              //   icon: Icon(
              //     Icons.sync,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Choose pomodoro sound',
              //   icon: Icon(
              //     Icons.sync,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Disable pomodoro sound or vibration',
              //   icon: Icon(
              //     Icons.sync,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Change pomodoro sound volume',
              //   icon: Icon(
              //     Icons.sync,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Backup and restore data',
              //   icon: Icon(
              //     Icons.sync,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Calendar Sync',
              //   icon: Icon(
              //     Icons.brightness_4,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Rate us',
              //   icon: Icon(
              //     Icons.brightness_4,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Share with friends',
              //   icon: Icon(
              //     Icons.brightness_4,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'Credits',
              //   icon: Icon(
              //     Icons.brightness_4,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // SettingsListTile(
              //   text: 'About us',
              //   icon: Icon(
              //     Icons.brightness_4,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
