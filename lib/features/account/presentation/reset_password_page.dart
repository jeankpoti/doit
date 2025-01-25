import 'package:flutter/material.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/loader_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../../../common_widget/title_large_text_widget.dart';
import '../../../helpers/validator.dart';

class ResetPasswordpage extends StatefulWidget {
  const ResetPasswordpage({super.key});

  @override
  State<ResetPasswordpage> createState() => _ResetPasswordpageState();
}

class _ResetPasswordpageState extends State<ResetPasswordpage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  void validateAndSend(buildContext) {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      // ref
      //     .read(resetPasswordControllerProvider.notifier)
      //     .sendPasswordResetEmail(context, _emailController.text.trim());
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Reset Password',
        isAction: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const TitleLargeTextWidget(
                          text: 'Reset password',
                        ),
                        const SizedBox(height: 25),
                        const TextWidget(
                          text:
                              'Please enter your email, and we will send you a verification code to your email.',
                        ),
                        const SizedBox(height: 45),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              TextFormFieldWidget(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                labelText: 'Email',
                                validator: (value) =>
                                    Validator.validateEmail(value!),
                              ),
                              const SizedBox(height: 45),
                              isLoading
                                  ? LoaderWidget()
                                  : ButtonWidget(
                                      onPressed: () => validateAndSend(context),
                                      text: 'Send'.toUpperCase(),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
