import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/deadline_controller.dart';
import 'package:study_master/model/deadline_model.dart';
import 'package:study_master/screens/sub-pages/add_deadline.dart';
import 'package:study_master/screens/widgets/calendar.dart';
import 'package:study_master/screens/widgets/deadline_display.dart';

class DeadlinePage extends StatefulWidget {
  final String email;

  const DeadlinePage({super.key, required this.email});

  @override
  State<DeadlinePage> createState() => _DeadlinePageState();
}

class _DeadlinePageState extends State<DeadlinePage> {
  final DeadlineController _deadlineController = DeadlineController();
  final List<Deadline> _deadlines = [];
  final bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  List<Deadline> _filteredDeadlines = [];

  Future<void> _fetchData() async {
    try {
      final weekDeadlines =
          await _deadlineController.getAllDeadlines(widget.email);
      setState(() {
        _deadlines.clear();
        _deadlines.addAll(weekDeadlines);
        _filteredDeadlines = _filterDeadlinesByDate(_selectedDate);
      });
    } catch (e) {
      // Handle errors if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load deadlines: $e')),
      );
    }
  }

  List<Deadline> _filterDeadlinesByDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date);
    return _deadlines.where((deadline) {
      return deadline.dueDate == formattedDate;
    }).toList();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredDeadlines = _filterDeadlinesByDate(date);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
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
                onPressed: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
                    context: context,
                    builder: (context) => AddDeadline(
                      rootContext: context,
                      onDeadlineCreated: _fetchData,
                    ),
                  ).whenComplete(() {
                    _fetchData();
                  });
                },
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          CustomCalendar(
            onDateSelected: (DateTime date) {
              _onDateSelected(date);
            },
          ),
          Expanded(
            child: _filteredDeadlines.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                        child: Column(
                    children: [
                      Image.asset(
                        'assets/images/Employeeworksondeadlines.png',
                        height: 300,
                        width: 300,
                      ),
                      const SizedBox(height: 20),
                      const Text('No deadlines yet!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 10),
                      const Text('Take a break while you can',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                              color: Colors.white)),
                    ],
                  )))
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView.builder(
                      itemCount: _filteredDeadlines.length,
                      itemBuilder: (context, index) {
                        final deadline = _filteredDeadlines[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: DeadlineTile(
                            date: deadline.dueDate,
                            time: deadline.reminderTime,
                            description: deadline.title,
                            deadline: deadline,
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
