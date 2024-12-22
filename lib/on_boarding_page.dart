import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common_widget/button_widget.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  int _selectedIndex = 0;

  String text = 'Next';

  bool isGetStarted = false;

  final List<Map<String, String>> _data = [
    {
      'imageUrl': 'assets/tasks.json',
      'title': 'Manage Schedule and Tasks',
      'description': 'It is never been easy to manage schedule and tasks.',
    },
    {
      'imageUrl': 'assets/aibuddy.json',
      'title': 'AI Buddy',
      'description':
          'Relax AI Buddy got your back! \nLet it do the work for you.',
    },
    {
      'imageUrl': 'assets/studybuddy.json',
      'title': 'Find a Study Buddy',
      'description':
          'Team up with a like-minded study buddy to stay motivated, share knowledge, and achieve better results.',
    },
  ];

  void _nextPage() {
    if (_currentPage < 2) {
      // Assuming there are 3 pages (0, 1, 2)
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });

      _showGetStarted();
    }
  }

  void _showGetStarted() {
    if (_currentPage == 2) {
      setState(() {
        isGetStarted = true;
      });
    } else {
      setState(() {
        isGetStarted = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    // AppRouter.markOnboardingComplete();

    // if (mounted) {
    //   context.replace('/signInView');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _data.length,
                    physics: const RangeMaintainingScrollPhysics(),
                    onPageChanged: (
                      index,
                    ) {
                      setState(() {
                        _selectedIndex = index;
                        _currentPage = index;
                      });

                      _showGetStarted();
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              onPressed: _completeOnboarding,
                              child: Text(
                                'Skip'.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ),
                          Lottie.asset(
                            _data[index]['imageUrl']!,
                            width: 400,
                            height: 300,
                            fit: BoxFit.fill,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            _data[index]['title']!,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _data[index]['description']!,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _data.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedContainer(
                        width: 50,
                        height: 10,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _selectedIndex == index
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: !isGetStarted
            ? ButtonWidget(
                text: 'Next'.toUpperCase(),
                onPressed: _nextPage,
                color: Theme.of(context).colorScheme.secondary,
              )
            : ButtonWidget(
                text: 'Get Started'.toUpperCase(),
                onPressed: _completeOnboarding,
                color: Theme.of(context).colorScheme.secondary,
              ),
      ),
    );
  }
}
