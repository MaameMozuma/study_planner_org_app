import 'package:flutter/material.dart';
import 'package:study_master/controller/schedule_controller.dart';
import 'package:study_master/model/schedule_model.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class EditSchedule extends StatefulWidget {
  final Schedule schedule;
  final BuildContext rootContext;

  const EditSchedule({super.key, required this.schedule, required this.rootContext});

  @override
  State<EditSchedule> createState() => _EditScheduleState();
}



class _EditScheduleState extends State<EditSchedule> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleController _scheduleController = ScheduleController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController courseController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 1, minute: 0);
  TextEditingController descriptionController = TextEditingController();
  String _priority = 'High';
  final String _setAlarm = 'false';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2021),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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

@override
void initState(){
    subjectController.text = widget.schedule.subject;
  courseController.text = widget.schedule.course;
  _selectedDate = DateTime.parse(widget.schedule.date);
  _startTime = _convertStringToTimeOfDay(widget.schedule.start);
  _endTime = _convertStringToTimeOfDay(widget.schedule.end);
  descriptionController.text = widget.schedule.description;
  _priority = widget.schedule.priority;

}

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
      builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else if (picked != _startTime) {
          _endTime = picked;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('You cannot choose the same start time and end time')),
          );
        }
      });
    }
  }

  void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ),
  );
}

    bool _validateFields() {
  if (subjectController.text.split(' ').length > 3) {
    _showError('Subject cannot be more than 3 words');
    return false;
  }

  if (courseController.text.split(' ').length > 3) {
    _showError('Course title cannot be more than 3 words');
    return false;
  }

  if (descriptionController.text.isEmpty ||
      subjectController.text.isEmpty ||
      courseController.text.isEmpty) {
    _showError('All fields are required');
    return false;
  }

  final startTime = TimeOfDay(hour: _startTime.hour, minute: _startTime.minute);
  final endTime = TimeOfDay(hour: _endTime.hour, minute: _endTime.minute);

  if (startTime.hour > endTime.hour ||
      (startTime.hour == endTime.hour && startTime.minute >= endTime.minute)) {
    _showError('Start time cannot be greater than or equal to end time');
    return false;
  }

  return true;
}

  void CreateSchedule(BuildContext context) async {
    if (_validateFields()) {
      final schedule = {
        'subject': subjectController.text,
        'course': courseController.text,
        'date': _selectedDate.toLocal().toString().split(' ')[0],
        'start': _formatTimeWithoutAmPm(_startTime),
        'end': _formatTimeWithoutAmPm(_endTime),
        'description': descriptionController.text,
        'priority': _priority,
        'userID': widget.schedule.userID,
      };
      print(schedule.entries);
      try {
        await _scheduleController.updateSchedule(schedule, widget.schedule.schedule_id);
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          const SnackBar(
            content: Text('Schedule edited successfully',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(widget.rootContext).showSnackBar(
          const SnackBar(
            content: Text('Failed to edit schedule',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          ),
        );
      }
    }
  }

  String _formatTimeWithoutAmPm(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(1, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${hour}h ${minute}m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        title: const Text(
            'Create Schedule',
            style: TextStyle(
                color: Color.fromRGBO(255, 63, 23, 1),
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.cancel_outlined,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(children: <Widget>[
              CustomTextField(
                  controller: subjectController,
                  labelText: 'Subject',
                  hintText: 'Enter a subject name',
                  maxLenOfInput: 40),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  controller: courseController,
                  labelText: 'Course',
                  hintText: 'Enter a course name',
                  maxLenOfInput: 40),
              const SizedBox(
                height: 20,
              ),
              CustomTextField(
                  controller: descriptionController,
                  labelText: 'Description',
                  hintText: 'Enter a brief description',
                  maxLenOfInput: 100),
              const SizedBox(
                height: 20,
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
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      tileColor: const Color.fromRGBO(38, 38, 38, 1),
                      title: const Text(
                        'Start Time:',
                        style:
                            TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      subtitle: Text(' ${_startTime.format(context)}', style: const TextStyle(fontSize: 15, color: Colors.white),),
                      onTap: () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      tileColor: const Color.fromRGBO(38, 38, 38, 1),
                      title: const Text(
                        'End Time:',
                        style:
                            TextStyle(fontSize: 15, color: Colors.white),
                      ),
                      subtitle: Text(' ${_endTime.format(context)}',
                      style:
                            const TextStyle(fontSize: 15, color: Colors.white),),
                      onTap: () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Priority',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPriorityOption('High'),
                  ),
                  Expanded(
                    child: _buildPriorityOption('Medium'),
                  ),
                  Expanded(
                    child: _buildPriorityOption('Low'),
                  ),
                ],
              ),
              const SizedBox(
                height: 50,
              ),
              CustomNormButton(
                text: 'Edit Schedule',
                onPressed: () {
                  CreateSchedule(context);
                },
              ),
            ]),
          )),
    );
  }

  Widget _buildPriorityOption(String value) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.35,
      child: RadioListTile<String>(
        contentPadding: EdgeInsets.zero,
        title: Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
        activeColor: Colors.white,
        value: value,
        tileColor: const Color.fromRGBO(29, 29, 29, 1),
        groupValue: _priority,
        onChanged: (String? newValue) {
          setState(() {
            _priority = newValue!;
          });
        },
      ),
    );
  }
}
