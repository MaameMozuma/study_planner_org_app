import 'package:flutter/material.dart';
import 'package:study_master/screens/main-pages/dashboard.dart';
import 'package:study_master/screens/main-pages/deadlines.dart';
import 'package:study_master/screens/main-pages/notes.dart';
import 'package:study_master/screens/main-pages/schedules.dart';
import 'package:study_master/screens/main-pages/timer.dart';

class CustomBottomNav extends StatefulWidget {
  final String email;

  const CustomBottomNav({super.key, required this.email});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 0;
  late List<Widget> pages;

  final List<IconData> _icons = const [
    Icons.home,
    Icons.list,
    Icons.calendar_month,
    Icons.menu_book,
    Icons.timer,
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      DashboardPage(
        email: widget.email,
      ),
      Schedules(email: widget.email,),
      DeadlinePage(email: widget.email),
      const NotesPage(),
      const TimerPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                height: 75,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 63, 23, 1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _icons.map((icon) {
                      int index = _icons.indexOf(icon);
                      bool isSelected = index == _selectedIndex;
                      return Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(10),
                                  child: Icon(
                                    icon,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white70,
                                    size: isSelected ? 55 : 32,
                                  ),
                                ),
                              ],
                            ),
                          ));
                    }).toList()),
              ))
        ],
      ),
    );
  }
}
