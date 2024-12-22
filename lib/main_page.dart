import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'features/todo/domain/repository/todo_repo.dart';
import 'features/pomodoro/presentation/pomodoro_page.dart';
import 'features/todo/presentation/todo_page.dart';

class MainPage extends StatefulWidget {
  final TodoRepo todoRepo;
  const MainPage({super.key, required this.todoRepo});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      TodoPage(
        todoRepo: widget.todoRepo,
      ),
      const PomodoroPage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const FaIcon(
          FontAwesomeIcons.house,
          size: 20,
        ),
        title: ("Todo"),
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const FaIcon(
          FontAwesomeIcons.calendarDays,
          size: 20,
        ),
        title: 'Pomodoro',
        activeColorPrimary: Theme.of(context).colorScheme.primary,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      backgroundColor: Theme.of(context).colorScheme.surface,
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      // confineInSafeArea: true,
      // backgroundColor: AppColors.bg, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset:
          true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      // hideNavigationBarWhenKeyboardShows:
      //     true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        // colorBehindNavBar: AppColors.bg,
      ),
      // popAllScreensOnTapOfSelectedTab: true,
      // popActionScreens: PopActionScreensType.all,
      // itemAnimationProperties: const ItemAnimationProperties(
      //   // Navigation Bar's items animation properties.
      //   duration: Duration(milliseconds: 200),
      //   curve: Curves.ease,
      // ),
      // screenTransitionAnimation: const ScreenTransitionAnimation(
      //   // Screen transition animation on change of selected tab.
      //   animateTabTransition: true,
      //   curve: Curves.ease,
      //   duration: Duration(milliseconds: 200),
      // ),
      navBarStyle:
          NavBarStyle.style3, // Choose the nav bar style with this property.
    );
  }

  // Future quitApp() => showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Center(
  //             child: AppIconWidget(
  //           icon: Icons.info_outline,
  //           iconSize: Dimensions.icon20,
  //           iconColor: Colors.white,
  //           backgroundColor: AppColors.mainColor,
  //         )),
  //         content: SmallTextWidget(
  //           text: "Veuillez vous connecter d'abord à Oanke!",
  //           size: Dimensions.font16,
  //           maxLines: 50,
  //           textAlign: TextAlign.center,
  //         ),
  //         actions: [
  //           GestureDetector(
  //             onTap: () => Get.back(),
  //             child: BigTextWidget(
  //               text: AppLocalizations.of(context)?.fermer ?? "",
  //               size: Dimensions.font16,
  //               color: AppColors.mainColor,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
}
