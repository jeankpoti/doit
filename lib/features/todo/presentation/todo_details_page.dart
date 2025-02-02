import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/text_small_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../../../common_widget/title_large_text_widget.dart';
import '../domain/models/todo.dart';

class TodoDetailsPage extends StatelessWidget {
  final Todo todo;
  const TodoDetailsPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Todo Details',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleLargeTextWidget(text: todo.title),
                const SizedBox(height: 16),
                TextWidget(text: todo.description ?? ''),
                const SizedBox(height: 16),
                TextSmallWidget(
                    text: 'Created at: ${DateFormat('MMMM dd, yyyy').format(
                  todo.createdAt,
                )}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
