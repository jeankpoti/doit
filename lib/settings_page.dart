import 'package:device_calendar/device_calendar.dart';
import 'package:do_it/common_widget/loader_widget.dart';
import 'package:do_it/common_widget/text_widget.dart';
import 'package:do_it/features/todo/domain/models/todo.dart';
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
import 'features/todo/presentation/todo_cubit.dart';
import 'features/todo/presentation/todo_state.dart';

class SetingsPage extends StatefulWidget {
  const SetingsPage({super.key});

  @override
  State<SetingsPage> createState() => _SetingsPageState();
}

class _SetingsPageState extends State<SetingsPage> {
  // Keep local UI-only state for the theme switch
  bool _isDarkMode = false;
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  @override
  void initState() {
    super.initState();
    // Load the todos when this page is first built
    context.read<TodoCubit>().loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final accountCubit = context.read<AccountCubit>();
    final todoCubit = context.read<TodoCubit>();

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
              return BlocBuilder<TodoCubit, TodoState>(
                  builder: (context, todoState) {
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
                        text: 'Sync Todos to Calendar',
                        icon: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () async {
                          todoCubit.syncTodosToCalendar(
                              context, todoState.todos);
                          // await _syncTodosToCalendar(todoState.todos);
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
                            if (context.mounted) {
                              ErrorMessageWidget.showError(
                                  context, 'Something went wrong!');
                            }
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
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              focusedBorder:
                                                  UnderlineInputBorder(
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
                                  builder: (context) =>
                                      const ResetPasswordpage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }

  // Future<void> _syncTodosToCalendar(List<Todo> todos) async {
  //   // Request permissions
  //   var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  //   if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
  //     permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  //     if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
  //       // Permissions not granted
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Calendar permissions are required to sync todos.'),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   // Retrieve calendars
  //   final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //   if (!calendarsResult.isSuccess || calendarsResult.data == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Could not retrieve calendars.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Filter writable calendars
  //   final writableCalendars = calendarsResult.data!
  //       .where((calendar) => calendar.isReadOnly == false)
  //       .toList();

  //   if (writableCalendars.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No writable calendars available.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Show calendar selection dialog
  //   final selectedCalendar = await showDialog<Calendar>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Select Calendar'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: writableCalendars.map((calendar) {
  //               return ListTile(
  //                 title: Text(calendar.name ?? 'Unnamed Calendar'),
  //                 onTap: () {
  //                   Navigator.pop(context, calendar);
  //                 },
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   if (selectedCalendar == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No calendar selected.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Show loading indicator
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const AlertDialog(
  //         content: Row(
  //           children: [
  //             CircularProgressIndicator(),
  //             SizedBox(width: 20),
  //             Text("Syncing todos..."),
  //           ],
  //         ),
  //       );
  //     },
  //   );

  //   try {
  //     // Retrieve events from the last 3 months only
  //     final DateTime startDate =
  //         DateTime.now().subtract(const Duration(days: 90));
  //     final DateTime endDate =
  //         DateTime.now().add(const Duration(days: 7)); // Include a week ahead

  //     final existingEventsResult = await _deviceCalendarPlugin.retrieveEvents(
  //       selectedCalendar.id,
  //       RetrieveEventsParams(
  //         startDate: startDate,
  //         endDate: endDate,
  //       ),
  //     );

  //     if (!existingEventsResult.isSuccess) {
  //       throw Exception(
  //           "Failed to retrieve existing events: ${existingEventsResult.errors.join(', ')}");
  //     }

  //     final existingEvents = existingEventsResult.data ?? [];
  //     print(
  //         "Retrieved ${existingEvents.length} existing events from the last 3 months");

  //     // Create a map of existing events by title for faster lookup
  //     final Map<String, Event> existingEventsByTitle = {};
  //     for (final event in existingEvents) {
  //       if (event.title != null) {
  //         existingEventsByTitle[event.title!] = event;
  //       }
  //     }

  //     int addedCount = 0;
  //     int updatedCount = 0;

  //     // Process each todo
  //     for (var todo in todos) {
  //       // For all-day events, use the todo creation date or current date
  //       final DateTime eventDate = todo.createdAt ?? DateTime.now();
  //       // Normalize to midnight for all-day events
  //       final DateTime normalizedDate =
  //           DateTime(eventDate.year, eventDate.month, eventDate.day);

  //       // Check if a todo with the same title already exists
  //       final existingEvent = existingEventsByTitle[todo.title];

  //       if (existingEvent != null) {
  //         // Update existing event
  //         existingEvent.description = todo.description;
  //         existingEvent.allDay = true;
  //         existingEvent.start = normalizedDate;
  //         existingEvent.end = normalizedDate;

  //         try {
  //           // Update the event
  //           final updateResult =
  //               await _deviceCalendarPlugin.createOrUpdateEvent(existingEvent);
  //           if (updateResult!.isSuccess) {
  //             updatedCount++;
  //           }
  //         } catch (e) {
  //           print("Exception updating event: $e");
  //         }
  //       } else {
  //         // Create new event
  //         final event = Event(
  //           selectedCalendar.id,
  //           title: todo.title,
  //           description: todo.description,
  //           allDay: true,
  //           start: normalizedDate,
  //           end: normalizedDate,
  //         );

  //         try {
  //           // Create the event
  //           final createResult =
  //               await _deviceCalendarPlugin.createOrUpdateEvent(event);
  //           if (createResult!.isSuccess) {
  //             addedCount++;
  //           }
  //         } catch (e) {
  //           print("Exception creating event: $e");
  //         }
  //       }
  //     }

  //     // Close loading dialog
  //     Navigator.of(context, rootNavigator: true).pop();

  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content:
  //             Text('Todos synced: $addedCount added, $updatedCount updated'),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //   } catch (e) {
  //     // Close loading dialog
  //     Navigator.of(context, rootNavigator: true).pop();

  //     // Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error syncing todos: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     print('Error syncing todos: $e');
  //   }
  // }

  // Future<void> _syncTodosToCalendar(List<Todo> todos) async {
  //   // Request permissions
  //   var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
  //   if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
  //     permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
  //     if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
  //       // Permissions not granted
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Calendar permissions are required to sync todos.'),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   // Retrieve calendars
  //   final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
  //   if (!calendarsResult.isSuccess || calendarsResult.data == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Could not retrieve calendars.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Filter writable calendars
  //   final writableCalendars = calendarsResult.data!
  //       .where((calendar) => calendar.isReadOnly == false)
  //       .toList();

  //   if (writableCalendars.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No writable calendars available.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Show calendar selection dialog
  //   final selectedCalendar = await showDialog<Calendar>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Select Calendar'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: writableCalendars.map((calendar) {
  //               return ListTile(
  //                 title: Text(calendar.name ?? 'Unnamed Calendar'),
  //                 onTap: () {
  //                   Navigator.pop(context, calendar);
  //                 },
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       );
  //     },
  //   );

  //   if (selectedCalendar == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('No calendar selected.'),
  //       ),
  //     );
  //     return;
  //   }

  //   // Create events for each todo
  //   for (var todo in todos) {
  //     final event = Event(
  //       selectedCalendar.id,
  //       title: todo.title,
  //       description: todo.description,
  //       allDay: true,
  //       start: todo.createdAt,
  //       end: todo.createdAt.add(const Duration(hours: 1)),
  //     );
  //     try {
  //       await _deviceCalendarPlugin.createOrUpdateEvent(event);

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Todos synced to calendar successfully.'),
  //         ),
  //       );
  //     } catch (e) {
  //       print('Error: $e');
  //       // If the event already exists, update it
  //     }
  //   }
  // }
}
