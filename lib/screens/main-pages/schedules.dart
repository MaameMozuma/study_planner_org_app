import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/schedule_controller.dart';
import 'package:study_master/model/schedule_model.dart';
import 'package:study_master/screens/sub-pages/create_schedule.dart';
import 'package:study_master/screens/widgets/calendar.dart';
import 'package:study_master/screens/widgets/schedules_card.dart';

class Schedules extends StatefulWidget {
  final String email;

  const Schedules({super.key, required this.email});

  @override
  State<Schedules> createState() => _SchedulesState();
}

class _SchedulesState extends State<Schedules> {
  final ScheduleController _scheduleController = ScheduleController();
  final List<Schedule> _schedules = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Schedule> _filteredSchedules = [];

  Future<void> _fetchData() async {
    try {
      final weekSchedules =
          await _scheduleController.getAllSchedules(widget.email);
      setState(() {
        _schedules.clear();
        _schedules.addAll(weekSchedules);
        _filteredSchedules = _filterSchedulesByDate(_selectedDate);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load schedules: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  List<Schedule> _filterSchedulesByDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);
    return _schedules.where((schedule) {
      return schedule.date == formattedDate;
    }).toList();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredSchedules = _filterSchedulesByDate(date);
    });
  }

  void _navigateToAddSchedulePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateSchedule(email: widget.email, rootContext: context),
      ),
    );

    if (result == true) {
      _fetchData(); // Refresh the schedules list if there's an update
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        elevation: 0,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () => _navigateToAddSchedulePage(context),
              ),
              
            ],
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: Column(
          children: [
            CustomCalendar(
              onDateSelected: _onDateSelected,
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredSchedules.isEmpty
                      ? Center(
                          child: Column(
                          children: [
                            const SizedBox(height: 50),
                            Image.asset('assets/images/Group.png'),
                            const SizedBox(height: 20),
                            const Text('No schedule today!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 10),
                            const Text(
                                'Rest if you have no work to do or \n create a schedule now.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white)),
                          ],
                        ))
                      : ListView.builder(
                          itemCount: _filteredSchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = _filteredSchedules[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SchedulesCard(
                                course: schedule.course,
                                subject: schedule.subject,
                                date: schedule.date,
                                time: schedule.start,
                                schedule: schedule,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
