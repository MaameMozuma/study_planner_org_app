import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/deadline_controller.dart';
import 'package:study_master/model/deadline_model.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class EditDeadline extends StatefulWidget {
  final BuildContext rootContext;
  final Deadline deadline;

  const EditDeadline({super.key, required this.rootContext, required this.deadline});

  @override
  State<EditDeadline> createState() => _EditDeadlineState();
}

class _EditDeadlineState extends State<EditDeadline> {
  TextEditingController subjectController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late DateTime _selectedDate = DateTime.now();
  TimeOfDay _loggedTime = const TimeOfDay(hour: 0, minute: 0);
  late User _user;
  final DeadlineController _deadlineController = DeadlineController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    subjectController.text = widget.deadline.title;
    descriptionController.text = widget.deadline.description;
    _selectedDate = DateTime.parse(widget.deadline.dueDate);
    _loggedTime = _convertStringToTimeOfDay(widget.deadline.reminderTime);
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    final regex = RegExp(r'(\d+)h (\d+)m');
    final match = regex.firstMatch(time);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      return const TimeOfDay(hour: 0, minute: 0);
    }
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

  String _formatTimeWithoutAmPm(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(1, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${hour}h ${minute}m';
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

  void _CreateDeadline(context) async {
      String subject = subjectController.text.trim();
  String description = descriptionController.text.trim();

  if (subject.isEmpty || description.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subject and/or description cannot be empty',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
    return;
  }

  if (subject.split(' ').length > 3) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subject cannot be more than 3 words',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
    return;
  }
  
    final deadlineDetails = {
      'title': subjectController.text,
      'description': descriptionController.text,
      'dueDate': _selectedDate.toLocal().toString().split(' ')[0],
      'userID': _user.email,
      'setReminder': 'false',
      'reminderTime': _formatTimeWithoutAmPm(_loggedTime),
    };
    print(deadlineDetails.entries);

    try {
      await _deadlineController.updateDealine(deadlineDetails, widget.deadline.deadline_id);
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        const SnackBar(
          content: Text('Deadline edited successfully', style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(widget.rootContext).showSnackBar(
        const SnackBar(
          content: Text('Failed to edit deadline', style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Edit Deadline',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(255, 63, 23, 1),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              CustomTextField(
                controller: subjectController,
                labelText: 'Subject',
                hintText: 'Enter a valid subject',
                readOnly: false,
                maxLenOfInput: 100,
              ),
              const SizedBox(height: 30),
              CustomTextField(
                controller: descriptionController,
                labelText: 'Description',
                hintText: 'Enter a valid description',
                readOnly: false,
                maxLenOfInput: 200,
              ),
              const SizedBox(height: 30),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                tileColor: const Color.fromRGBO(38, 38, 38, 1),
                title: const Text(
                  'Time:',
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
                  text: 'Edit Deadline',
                  onPressed: () {
                    _CreateDeadline(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
