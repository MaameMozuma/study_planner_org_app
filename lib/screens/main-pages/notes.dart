import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/note_controller.dart';
import 'package:study_master/model/note_model.dart';
import 'package:study_master/screens/sub-pages/add_notes.dart';
import 'package:study_master/screens/widgets/notes_card.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteController _noteController = NoteController();
  late Future<List<Note>> _notes;
  late User _user;

  @override
  void initState() {
    super.initState();
    _initializeUserAndNotes();
  }

  void _initializeUserAndNotes() async {
    _user = FirebaseAuth.instance.currentUser!;
    setState(() {
      _notes = _fetchData(_user.email!);
    });
    print('len: $_notes');  
  }

  Future<List<Note>> _fetchData(String email) async {
    return await _noteController.getAllNotes(email);
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _notes = _fetchData(_user.email!);
    });
  }

  void _deleteNote(Note note) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
          title: const Text(
            'Confirm Deletion',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this note?',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // User pressed "Cancel"
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // User pressed "Delete"
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Color.fromRGBO(255, 63, 23, 1)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _noteController.deleteNote(note.note_id);
        setState(() {
          _notes = _fetchData(_user.email!);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Successfully deleted note',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete note: $e',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewNotePage(),
                ),
              );
              if (result != null) {
                var data = {
                  'userID': _user.email!,
                  'title': result['title'],
                  'content': result['content'],
                  'lastModified': DateTime.now().toString(),
                  'createdDate': DateTime.now().toString(),
                  'attachmentURLS' : result['attachmentURLS'],
                };
                print(data.entries);
                await _noteController.createNote(data);
                setState(() {
                  _notes = _fetchData(_user.email!);
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Note>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}, ${snapshot.stackTrace}', style: const TextStyle(color: Colors.white));
          } else if (snapshot.hasData) {
            List<Note> notes = snapshot.data!;
            print('len: ${notes.length}');
            if (notes.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Image.asset('assets/images/BoyWritingNote.png'),
                      const SizedBox(height: 0),
                      const Text(
                        'No Notes Yet!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refreshNotes,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return NotesCard(
                    note: notes[index],
                    onDelete: () {
                      _deleteNote(notes[index]);
                    },
                    rootContext: context,
                  );
                },
              ),
            );
          } else {
            return const Text('No data', style: TextStyle(color: Colors.white));
          }
        },
      ),
    );
  }
}
