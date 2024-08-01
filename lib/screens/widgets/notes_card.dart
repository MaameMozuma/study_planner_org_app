import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_master/controller/note_controller.dart';
import 'package:study_master/model/note_model.dart';
import 'package:study_master/screens/sub-pages/edit_note.dart';

class NotesCard extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final BuildContext rootContext;

  const NotesCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.rootContext,
  });

  @override
  Widget build(BuildContext context) {
    final name = note.title;
    final content = note.content;
    final dateLogged = note.lastModified;
    final DateTime dueDate = DateTime.parse(dateLogged);
    final DateFormat formatter = DateFormat('d MMMM, yyyy');
    final String formattedDate = formatter.format(dueDate);
    NoteController noteController = NoteController();

    return Card(
      color: const Color.fromRGBO(38, 38, 38, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        tileColor: const Color.fromRGBO(38, 38, 38, 1),
        contentPadding: const EdgeInsets.all(10),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () async {
                  final updatedNote = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNote(note: note),
                    ),
                  );

                  if (updatedNote != null) {
                    var data = {
                      'title': updatedNote['title'],
                      'content': updatedNote['content'],
                      'lastModified': DateTime.now().toIso8601String(),
                    };
                    bool isSuccessful = await noteController.updateNote(
                      data,
                      note.note_id,
                    );

                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSuccessful
                              ? 'Schedule edited successfully'
                              : 'Failed to edit schedule',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
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
