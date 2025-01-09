import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/apple_signin_button_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/google_signin_button_widget.dart';
import '../../../common_widget/loader_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../../../common_widget/title_large_text_widget.dart';
import '../../../helpers/validator.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isPasswordVisible = true, isLoading = false;

  void validateAndSave(buildContext) {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      // ref.read(signInControllerProvider.notifier).signIn(
      //       context,
      //       _emailController.text.trim(),
      //       _passwordController.text.trim(),
      //     );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Sign In',
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
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Center(
                    child: Column(
                      children: [
                        const TitleLargeTextWidget(
                          text: 'Sign In',
                        ),
                        const SizedBox(height: 25),
                        const TextWidget(
                          text: 'Connect to your account',
                        ),
                        // Text(
                        //   'Connect to your account',
                        //   style: AppTextStyles.titleMd,
                        // ),
                        const SizedBox(height: 5),
                        const TextWidget(
                          text: 'Enter your email and password to sign in',
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
                              const SizedBox(height: 20),
                              TextFormFieldWidget(
                                controller: _passwordController,
                                obscureText: isPasswordVisible,
                                labelText: 'Password',
                                suffixIcon: GestureDetector(
                                  onTap: () => {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    }),
                                  },
                                  child: Icon(
                                    Icons.visibility_off,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please provide a password'
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: () => {
                                  // context.goNamed(
                                  //     AppRoute.resetPasswordView.name,
                                  //   ),
                                },
                                child: const TextWidget(
                                  text: 'Forgot password?',
                                ),
                              ),
                              const SizedBox(height: 45),
                              isLoading
                                  ? const LoaderWidget()
                                  : ButtonWidget(
                                      onPressed: () => validateAndSave(context),
                                      text: ' Sign In',
                                      // color: Theme.of(context).colorScheme.primary,
                                    ),
                              const SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const TextWidget(text: 'No account? '),
                                  TextButton(
                                    onPressed: () => {
                                      //  context.goNamed(AppRoute.signUpView.name),
                                    },
                                    child: const TextWidget(text: 'Sign Up '),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Flexible(
                                    child: Divider(
                                      thickness: 1,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: TextWidget(
                                      text: 'Or sign in with',
                                    ),
                                  ),
                                  Flexible(
                                    child: Divider(
                                      thickness: 1,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              GoogleSigninButtonWidget(
                                onPressed: () => {
                                  // signInController.signInWithGoogle(context),
                                },
                                text: Text(
                                  ' Google',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              if (Platform.isIOS) const SizedBox(height: 25),
                              if (Platform.isIOS)
                                AppleSigninButtonWidget(
                                  onPressed: () => {
                                    // signInController.signInWithApple(context),
                                  },
                                  text: Text(
                                    ' Apple',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const TextWidget(
                                text: 'By signing up, you agree to our '),
                            GestureDetector(
                              onTap: () => {
                                //     TermsConditionsWidget.termsConditionsWidget(
                                //   context: context,
                                // ),
                              },
                              child: const TextWidget(
                                  text: 'Terms and Conditions'),
                            ),
                          ],
                        ),
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
