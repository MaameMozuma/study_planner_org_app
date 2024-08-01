
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/schedule_controller.dart';
import 'package:study_master/model/schedule_model.dart';
import 'package:study_master/screens/sub-pages/edit_schedule.dart';

class TaskDetailModal extends StatelessWidget {
  final Map<String, dynamic> task;
  const TaskDetailModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final DateTime dueDate = DateTime.parse(task['date']);
    final DateFormat formatter = DateFormat('d MMMM, yyyy');
    final String formattedDate = formatter.format(dueDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task['course'],
            style: const TextStyle(
              color: Colors.lightBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task['subject'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task['priority'],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  // Navigate to the CreateSchedule screen with the current schedule data
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditSchedule(
                          schedule: Schedule.fromMap(task),
                          rootContext: context),
                    ),
                  );
                  // Refresh the schedules after editing
                  Navigator.pop(context, true); // Close the modal
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  // Show a confirmation dialog before deleting
                  final bool? shouldDelete = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
                        title: const Text(
                          'Confirm Delete',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this schedule?',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel',
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 63, 23, 1))),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: Color.fromRGBO(255, 63, 23, 1))),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldDelete == true) {
                    try {
                      // Call the delete function from your controller
                      await ScheduleController()
                          .deleteSchedule(task['schedule_id']);
                      Navigator.pop(context, true); // Close the modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Schedule deleted successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete schedule: $e',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'From',
                style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
              ),
              const SizedBox(width: 8),
              Text(
                task['start'],
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text(
                'To',
                style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
              ),
              const SizedBox(width: 6),
              Text(
                task['end'],
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task['description'],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
