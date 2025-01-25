import 'package:flutter/material.dart';

import 'text_widget.dart';

class SuccessMessageWidget {
  static void showSucess(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: TextWidget(
          text: errorMessage,
        ),
      ),
    );
  }
}
