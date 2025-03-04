import 'package:do_it/common_widget/loader_widget.dart';
import 'package:do_it/common_widget/text_widget.dart';
import 'package:do_it/theme/theme_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_widget/app_bar_widget.dart';
import 'common_widget/error_message_widget.dart';
import 'common_widget/settings_list_tile.dart';
import 'features/account/presentation/account_cubit.dart';
import 'features/account/presentation/account_state.dart';
import 'features/account/presentation/reset_password_page.dart';
import 'features/account/presentation/sign_in_page.dart';
import 'features/todo/presentation/completed_todo_page.dart';

class SetingsPage extends StatefulWidget {
  const SetingsPage({super.key});

  @override
  State<SetingsPage> createState() => _SetingsPageState();
}

class _SetingsPageState extends State<SetingsPage> {
  // Keep local UI-only state for the theme switch
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Settings',
        isAction: false,
      ),
      body: SafeArea(
        child: BlocListener<AccountCubit, AccountState>(
          listener: (context, accountState) {
            if (accountState.errorMsg != null) {
              ErrorMessageWidget.showError(context, 'Something went wrong!');
            } else if (accountState.isSignOut) {
              ErrorMessageWidget.showError(context, 'Sign out successful!');
              // Reset isSignOut state
              // context.read<AccountCubit>().resetSignOut();
            }
          },
          child: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              final user = FirebaseAuth.instance.currentUser;

              if (accountState.isLoading) {
                return const Center(child: LoaderWidget());
              }

              return SingleChildScrollView(
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
                          });
                          context.read<ThemeCubit>().toggleTheme();
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
                      text: 'Rate Us',
                      icon: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () async {
                        const url =
                            "https://itunes.apple.com/app/id\id6739957932?action=write-review";
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                    SettingsListTile(
                      text: 'Share with Friends',
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onTap: () {
                        Share.share(
                          'Check out this amazing app: https://apps.apple.com/app/id6739957932',
                        );
                      },
                    ),
                    if (user == null)
                      SettingsListTile(
                        text: 'Sign in to Sync data',
                        icon: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ),
                        ),
                      ),
                    if (user != null)
                      SettingsListTile(
                        text: 'Sign out',
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () async {
                          await accountCubit.signOut();
                        },
                      ),
                    if (user != null)
                      ExpansionTile(
                        title: const TextWidget(
                          text: 'Account Settings',
                        ),
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.person,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: const TextWidget(
                              text: 'Delete Account',
                            ),
                            onTap: () async {
                              String confirmText = '';

                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    title: const TextWidget(
                                      text: 'Delete Account',
                                    ),
                                    content: Column(
                                      spacing: 16,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const TextWidget(
                                          text:
                                              'This action cannot be undone. All your data will be deleted.  Please type "DELETE" to confirm.',
                                        ),
                                        TextField(
                                          onChanged: (value) =>
                                              confirmText = value,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          decoration: InputDecoration(
                                            hintText: 'Type DELETE',
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            labelStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            focusColor: Colors.white,
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .titleMedium!,
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (confirmText == 'DELETE') {
                                            Navigator.pop(context, true);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Please type DELETE to confirm'),
                                              ),
                                            );
                                          }
                                        },
                                        child: Text(
                                          'Delete Account',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true && context.mounted) {
                                await accountCubit
                                    .deleteUserWithHisData(context);
                              }
                            },
                          ),
                          SettingsListTile(
                            text: 'Reset Password',
                            icon: Icon(
                              Icons.logout,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ResetPasswordpage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// import 'package:do_it/theme/theme_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'common_widget/app_bar_widget.dart';
// import 'common_widget/settings_list_tile.dart';
// import 'features/account/presentation/account_cubit.dart';
// import 'features/account/presentation/sign_in_page.dart';
// import 'features/todo/presentation/completed_todo_page.dart';

// class SetingsPage extends StatefulWidget {
//   const SetingsPage({super.key});

//   @override
//   State<SetingsPage> createState() => _SetingsPageState();
// }

// class _SetingsPageState extends State<SetingsPage> {
//   bool _isDarkMode = false;
//   @override
//   Widget build(BuildContext context) {
//     final accountCubit = context.read<AccountCubit>();

//     return Scaffold(
//       appBar: const AppBarWidget(
//         title: 'Settings',
//         isAction: false,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             spacing: 10,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SettingsListTile(
//                 text: 'Change theme',
//                 icon: Icon(
//                   Icons.brightness_4,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 switcher: Switch(
//                   value: _isDarkMode,
//                   onChanged: (value) {
//                     setState(() {
//                       _isDarkMode = value;
//                       // Add your theme change logic here
//                       context.read<ThemeCubit>().toggleTheme();
//                     });
//                   },
//                 ),
//               ),
//               SettingsListTile(
//                 text: 'Historics',
//                 icon: Icon(
//                   Icons.history,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const CompletedTodoPage(),
//                   ),
//                 ),
//               ),

//               SettingsListTile(
//                 text: 'Sign in to Sync data',
//                 icon: Icon(
//                   Icons.history,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const SignInPage(),
//                   ),
//                 ),
//               ),

//               SettingsListTile(
//                   text: 'Sign out',
//                   icon: Icon(
//                     Icons.logout,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   onTap: () => {
//                         accountCubit.signOut(),
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SignInPage(),
//                           ),
//                         ),
//                       }),
//               // SettingsListTile(
//               //   text: 'Configure pomodoro ',
//               //   icon: Icon(
//               //     Icons.sync,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Choose pomodoro sound',
//               //   icon: Icon(
//               //     Icons.sync,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Disable pomodoro sound or vibration',
//               //   icon: Icon(
//               //     Icons.sync,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Change pomodoro sound volume',
//               //   icon: Icon(
//               //     Icons.sync,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Backup and restore data',
//               //   icon: Icon(
//               //     Icons.sync,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Calendar Sync',
//               //   icon: Icon(
//               //     Icons.brightness_4,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Rate us',
//               //   icon: Icon(
//               //     Icons.brightness_4,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Share with friends',
//               //   icon: Icon(
//               //     Icons.brightness_4,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'Credits',
//               //   icon: Icon(
//               //     Icons.brightness_4,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//               // SettingsListTile(
//               //   text: 'About us',
//               //   icon: Icon(
//               //     Icons.brightness_4,
//               //     color: Theme.of(context).colorScheme.primary,
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
