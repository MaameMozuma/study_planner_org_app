import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/deadline_controller.dart';
import 'package:study_master/model/deadline_model.dart';
import 'package:study_master/screens/sub-pages/edit_deadline.dart';

class DeadlineModal extends StatelessWidget {
  final Map<String, dynamic> task;
  const DeadlineModal({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final DateTime dueDate = DateTime.parse(task['dueDate']);
    final DateFormat formatter = DateFormat('d MMMM, yyyy');
    final String formattedDate = formatter.format(dueDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task['title'],
            style: const TextStyle(
              color: Colors.lightBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
            formattedDate,
            style: const TextStyle(
              color: Color.fromRGBO(255, 63, 23, 1),
              fontSize: 14,
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
                      builder: (context) => EditDeadline(
                          deadline: Deadline.fromMap(task),
                          rootContext: context),
                    ),
                  );
                  // Refresh the schedules after editing
                  Navigator.pop(context); // Close the modal
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
                          'Are you sure you want to delete this deadline?',
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
                      await DeadlineController()
                          .deleteDeadline(task['deadline_id']);
                      Navigator.pop(context); // Close the modal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Deadline deleted successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Color.fromRGBO(255, 63, 23, 1),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to delete deadline: $e',
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
            task['description'],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
