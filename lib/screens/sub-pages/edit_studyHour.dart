import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/studyhour_controller.dart';
import 'package:study_master/model/studyhour_model.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class EditStudyhour extends StatefulWidget {
  final StudyHour studyHour;
  final BuildContext rootContext;

  const EditStudyhour({super.key, required this.studyHour, required this.rootContext});

  @override
  State<EditStudyhour> createState() => _EditStudyhourState();
}

class _EditStudyhourState extends State<EditStudyhour> {
  TextEditingController subjectController = TextEditingController();
  TextEditingController dateLoggedController = TextEditingController();
  late DateTime _selectedDate;
  TimeOfDay _loggedTime = const TimeOfDay(hour: 0, minute: 0);
  final StudyhourController _studyhourController = StudyhourController();

  @override
  void initState() {
    super.initState();
    subjectController.text = widget.studyHour.course;
    _selectedDate = DateTime.parse(widget.studyHour.loggedDate);
    _loggedTime = _convertStringToTimeOfDay(widget.studyHour.hoursLogged);
  }

  String _formatTimeWithoutAmPm(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
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

void _EditStudyhour(BuildContext context) async {
  final course = subjectController.text.trim();
  final hoursLogged = _formatTimeWithoutAmPm(_loggedTime);
  final loggedDate = _formatDate(_selectedDate);

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
    'userID': widget.studyHour.userID,
  };
  
  try {
    bool isUpdated = await _studyhourController.updateStudyhour(timerDetails, widget.studyHour.studyhour_id);
    if (isUpdated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study hours updated successfully',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update study hours',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to update study hours',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
      ),
    );
  }
}


  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(alignment: Alignment.center, 
          child: Text(
            'Edit Study Hours',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 63, 23, 1)),
          ),),
          const SizedBox(height: 50,),
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
          const SizedBox(
            height: 30,
          ),
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
          const SizedBox(height: 40,),
          CustomNormButton(
                text: 'Edit Study Hours',
                onPressed: () {
                  _EditStudyhour(context);
                },
              ),
        ],
      ),
    );
  }
}
