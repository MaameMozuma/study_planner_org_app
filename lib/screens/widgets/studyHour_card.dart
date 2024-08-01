import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/model/studyhour_model.dart';
import 'package:study_master/screens/sub-pages/edit_studyHour.dart';

class StudyHourCard extends StatelessWidget {
  final StudyHour studyHour;
  final VoidCallback onDelete;
  final BuildContext rootContext;

  const StudyHourCard({
    super.key,
    required this.studyHour,
    required this.onDelete,
    required this.rootContext,
  });

  @override
  Widget build(BuildContext context) {
    //final Formatted = DateFormat.Hm().format(meal.date);
    final name = studyHour.course;
    final hrsLogged = studyHour.hoursLogged;
    final dateLogged = studyHour.loggedDate;
    final DateTime dueDate = DateTime.parse(dateLogged);
    final DateFormat formatter = DateFormat('d MMMM, yyyy');
    final String formattedDate = formatter.format(dueDate);

    return Card(
      color: const Color.fromRGBO(38, 38, 38, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          // Create an instance of RoundedRectangleBorder
          borderRadius:
              BorderRadius.circular(15.0), // Adjust the radius as needed
        ),
        tileColor: const Color.fromRGBO(38, 38, 38, 1),
        contentPadding: const EdgeInsets.all(10),
        title: Text(name,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hrsLogged,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 5,),
            Text(formattedDate,
                style: const TextStyle(
                    fontSize: 14, color: Color.fromRGBO(255, 63, 23, 1)))
          ],
        ),
        trailing: SizedBox(
          width: 96, // Restrict the width of the trailing row
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
                      context: context, builder: (context) => EditStudyhour(studyHour: studyHour, rootContext: rootContext),);
                  },
                  icon: const Icon(Icons.edit, color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
