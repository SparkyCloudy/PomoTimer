import 'package:flutter/material.dart';
import 'package:pomotimer/views/config.dart';
import 'package:pomotimer/views/history.dart';
import 'package:pomotimer/views/timer.dart';

class FixedUi extends StatefulWidget {
  const FixedUi({super.key, required this.title});

  final String title;

  @override
  State<FixedUi> createState() => _FixedUiState();
}

class _FixedUiState extends State<FixedUi> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/images/PomoTimer.png'),
          title: const Text(
            "PomoTimer",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.more_vert,
                size: 24,
              ),
              onPressed: () {

              },
            )
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (selectedIndex) {
            setState(() {
              currentPageIndex = selectedIndex;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.app_settings_alt),
              icon: Icon(Icons.app_settings_alt_outlined),
              label: 'Config',
            ),
            NavigationDestination(
              selectedIcon:
                  Badge(isLabelVisible: false, child: Icon(Icons.timer)),
              icon: Badge(
                  isLabelVisible: false, child: Icon(Icons.timer_outlined)),
              label: 'Timer',
            ),
            NavigationDestination(
              icon: Badge(
                  isLabelVisible: false, child: Icon(Icons.history_outlined)),
              label: 'History',
            ),
          ],
        ),
        body: [
          const PomoConfig(),
          const PomoTimer(),
          const PomoHistory()
        ][currentPageIndex]);
  }
}
