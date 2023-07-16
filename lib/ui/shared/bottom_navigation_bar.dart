import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int selectedPageIndex = 2;

  void navigateTo(String routeName) {
    // NavigationService.navigateTo(routeName);
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        color: Theme.of(context).colorScheme.secondary,
        animationDuration: const Duration(milliseconds: 400),
        index: selectedPageIndex,
        onTap: (value) {
          selectedPageIndex = value;
        },
        items: const [
          Icon(
            Icons.bar_chart_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.assignment,
            color: Colors.white,
          ),
          Icon(
            Icons.home_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.person_pin_rounded,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            color: Colors.white,
          ),
        ]);
  }
}
