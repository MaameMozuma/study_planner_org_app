import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/studyhour_controller.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class CreateStudyhour extends StatefulWidget {
    final BuildContext rootContext;
    final VoidCallback onStudyHourCreated; 

  const CreateStudyhour({super.key, required this.rootContext, required this.onStudyHourCreated});

  @override
  State<CreateStudyhour> createState() => _CreateStudyhourState();
}

class _CreateStudyhourState extends State<CreateStudyhour> {
  TextEditingController subjectController = TextEditingController();
  TextEditingController hoursLoggedController = TextEditingController();
  TextEditingController dateLoggedController = TextEditingController();
  late DateTime _selectedDate = DateTime.now();
  TimeOfDay _loggedTime = const TimeOfDay(hour: 0, minute: 0);
  late User _user;
  final StudyhourController _studyhourController = StudyhourController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
  }


  String _formatTimeWithoutAmPm(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(1, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${hour}h ${minute}m';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _loggedTime,
      builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
    );
    if (picked != null && picked != _loggedTime) {
      setState(() {
        _loggedTime = picked;
      });
    }
  }

    TimeOfDay _convertStringToTimeOfDay(String time) {
    // Assuming the time is in "3h 00m" format
    final regex = RegExp(r'(\d+)h (\d+)m');
    final match = regex.firstMatch(time);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      // Return a default value if parsing fails
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }


void _CreateStudyhour(BuildContext context) async {
  final course = subjectController.text.trim();
  final hoursLogged = _formatTimeWithoutAmPm(_loggedTime);
  final loggedDate = _selectedDate.toLocal().toString().split(' ')[0];

  // Validation
  if (course.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course field cannot be empty',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      ),
    );
    Navigator.pop(context);
    return;
  }

  final courseWords = course.split(RegExp(r'\s+'));
  if (courseWords.length > 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Course cannot be more than 3 words',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      ),
    );
    Navigator.pop(context);
    return;
  }

  // Proceed if validation is successful
  final timerDetails = {
    'course': course,
    'hoursLogged': hoursLogged,
    'loggedDate': loggedDate,
    'userID': _user.email,
  };
  print(timerDetails.entries);

  try {
    await _studyhourController.createStudyHour(timerDetails);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Study hours logged successfully',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      ),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to log study hours',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      ),
    );
  }
}


  @override
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Log Study Hours',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(255, 63, 23, 1)),
            ),
          ),
          const SizedBox(height: 50),
          CustomTextField(
            controller: subjectController,
            labelText: 'Course',
            hintText: 'Enter a valid course',
            readOnly: false,
            maxLenOfInput: 100,
          ),
          const SizedBox(height: 30),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            tileColor: const Color.fromRGBO(38, 38, 38, 1),
            title: const Text(
              'Number of hours studied:',
              style: TextStyle(fontSize: 15, color: Colors.white),
            ),
            subtitle: Text(
              _formatTimeWithoutAmPm(_loggedTime),
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            onTap: () => _selectTime(context),
          ),
          const SizedBox(height: 30),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            tileColor: const Color.fromRGBO(38, 38, 38, 1),
            title: Text(
              'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 15, color: Colors.white),
            ),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.center,
            child: CustomNormButton(
              text: 'Create Study Hours',
              onPressed: () {
                _CreateStudyhour(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}
