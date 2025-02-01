import 'package:do_it/on_boarding_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/todo/domain/repository/todo_repo.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  final TodoRepo todoRepo;
  const SplashPage({super.key, required this.todoRepo});

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _spinnerAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Spinner animation for the progress indicator
    _spinnerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _navigateToNext() async {
    // Wait for splash animation
    // await Future.delayed(const Duration(seconds: 3));
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Check onboarding status
    // final prefs = await SharedPreferences.getInstance();
    // final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!mounted) return;

    // Fade out animation before navigation
    await _controller.reverse();

    // if (isFirstTime && mounted) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const OnBoardingPage()),
    //   );
    // } else {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(todoRepo: widget.todoRepo),
        ),
      );
    }
    // }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          'Work Snap',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        )

                        //  Image.asset(
                        //   'assets/icons/iwadi_logo.png',
                        //   width: 100,
                        //   height: 100,
                        // ),
                        ),
                  ),
                ),
                // const SizedBox(height: 20),
                // FadeTransition(
                //   opacity: _spinnerAnimation,
                //   child: Text(
                //     'Iwadi',
                //     // style: AppTextStyles.titleMd,
                //   ),
                // ),
                const SizedBox(height: 40),
                // Animated progress indicator
                FadeTransition(
                  opacity: _spinnerAnimation,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onSurface,
                      ),
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
