import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/model/schedule_model.dart';
import 'package:study_master/screens/widgets/task_detail_modal.dart';

class SchedulesCard extends StatelessWidget {
    final String date;
  final String time;
  final String course;
  final String subject;
  final Schedule schedule;
  const SchedulesCard({super.key, required this.date, required this.time, required this.course, required this.subject, required this.schedule});

  @override
  Widget build(BuildContext context) {
        final DateTime dueDate = DateTime.parse(date);
    final DateFormat formatter = DateFormat('d MMMM, yyyy');
    final String formattedDate = formatter.format(dueDate);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(29, 29, 29, 1), // Dark background color
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          const Divider(
                    color: Color.fromRGBO(63, 63, 63, 1), // Highlight color for divider
                    thickness: 2.0,
                  ),
          Row(
            children: [
                          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 80.0), // Adjust maxWidth as needed
            child: Text(
              formattedDate,
              style: const TextStyle(
                color: Color.fromRGBO(255, 63, 23, 1), // Color for time
                fontSize: 16.0,
              ),
            ),
          ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4.0),
                  Text(
                    course,
                    style: const TextStyle(
                      color: Colors.white, // Color for time
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white, // Color for description
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                ],
              ),
              const Spacer(),
              IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
                context: context,
                builder: (context) => TaskDetailModal(
                  task: schedule.toMap(),
                ),
              );
            },
          ),
            ],
          ),
          const Divider(
                    color: Color.fromRGBO(63, 63, 63, 1), // Highlight color for divider
                    thickness: 2.0,
                  ),
        ],
      ),
    );
  }
}