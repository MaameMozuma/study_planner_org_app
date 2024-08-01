import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/studytimer_controller.dart';
import 'package:study_master/screens/sub-pages/view_studylogs.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;
  double _sliderValue = 0;
  late User _user;
  String? _startTime;
  String? _endTime;
  TextEditingController subjectController = TextEditingController();
  final StudytimerController _studytimerController = StudytimerController();

  // State variables for icon colors
  Color _playIconColor = Colors.white;
  Color _pauseIconColor = Colors.white;
  Color _resetIconColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }

void _createTimer(BuildContext context) async {
  String? courseName = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        title: const Text('Enter Course Name', style: TextStyle(color: Colors.white)),
        content: CustomTextField(
          controller: subjectController,
          labelText: 'Course',
          hintText: 'Enter a valid course name',
          maxLenOfInput: 30,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1))),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK', style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1))),
            onPressed: () {
              Navigator.of(context).pop(subjectController.text);
            },
          ),
        ],
      );
    },
  );

  if (courseName != null && courseName.isNotEmpty) {
    // Validation
    final courseWords = courseName.trim().split(RegExp(r'\s+'));
    if (courseWords.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course cannot be more than 3 words',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        ),
      );
      return;
    }

    // Proceed if validation is successful
    final timerDetails = {
      'course': courseName,
      'startTime': _startTime,
      'endTime': _endTime,
      'userID': _user.email,
    };

    try {
      await _studytimerController.createStudytimer(timerDetails);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study time saved successfully',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create study time',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course field cannot be empty',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
      ),
    );
  }
}

  void _startTimer() {
    if (!_isRunning) {
      _startTime = DateFormat('HH:mm').format(DateTime.now());

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_seconds > 0) {
            _seconds--;
          } else {
            _timer?.cancel();
            setState(() {
              _isRunning = false;
              _playIconColor = Colors.white;
            });
            _endTime = DateFormat('HH:mm').format(DateTime.now());
            _createTimer(context);
          }
        });
      });
      setState(() {
        _isRunning = true;
        _playIconColor = const Color.fromRGBO(
            255, 63, 23, 1); // Change play icon color when active
        _pauseIconColor = Colors.white;
        _resetIconColor = Colors.white;
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isRunning = false;
        _playIconColor = Colors.white; // Reset play icon color
        _pauseIconColor = const Color.fromRGBO(255, 63, 23, 1);
      });
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = (_sliderValue * 60).toInt();
      _isRunning = false;
      _playIconColor = Colors.white; // Reset play icon color
      _pauseIconColor = Colors.white; // Reset pause icon color
      _resetIconColor = const Color.fromRGBO(255, 63, 23, 1);
    });
  }

  void _setTimer() {
    setState(() {
      _seconds = (_sliderValue * 60).toInt();
    });
  }

  String get _formattedTime {
    int hours = _seconds ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        title: const Text('Study Timer',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewStudyHourLogs(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 110),
            const Text(
              'Set Timer (minutes)',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Slider(
              value: _sliderValue,
              inactiveColor: Colors.grey,
              activeColor: const Color.fromRGBO(255, 63, 23, 1),
              min: 0,
              max: 120,
              divisions: 120,
              label: _sliderValue.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
            SizedBox(
              width: 120,
              height: 70,
              child: ElevatedButton(
                onPressed: _setTimer,
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(const Color.fromRGBO(255, 63, 23, 1)),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 15)),
                  shape: WidgetStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  )),
                ),
                child: const Text('Set Timer',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.normal)),
              ),
            ),
            const SizedBox(height: 60),
            Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(40, 40, 40, 1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                          color: Color.fromRGBO(255, 63, 23, 1), fontSize: 48),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.restart_alt,
                              size: 30, color: _resetIconColor),
                          onPressed: _resetTimer,
                        ),
                        IconButton(
                          icon: Icon(Icons.play_arrow,
                              size: 30, color: _playIconColor),
                          onPressed: _startTimer,
                        ),
                        IconButton(
                          icon: Icon(Icons.pause,
                              size: 30, color: _pauseIconColor),
                          onPressed: _pauseTimer,
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
    );
  }
}
