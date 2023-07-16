import 'package:cambio_veraz/ui/shared/app_bar.dart';
import 'package:cambio_veraz/ui/shared/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class PagesLayout extends StatelessWidget {
  final Widget child;

  const PagesLayout({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffEDF1F2),
        appBar: CustomAppBar(),
        bottomNavigationBar: const CustomBottomNavigationBar(),
        body: child);
  }
}
