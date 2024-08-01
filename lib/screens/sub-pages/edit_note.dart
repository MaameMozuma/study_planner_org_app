import 'package:flutter/material.dart';
import 'package:study_master/model/note_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class EditNote extends StatefulWidget {
  final Note note;
  const EditNote({super.key, required this.note});

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Form key

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
  }

  Future<Uint8List> _getImageData(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> _exportNoteAsPdf() async {
    final pdf = pw.Document();

    final imageWidgets = <pw.Widget>[];
    for (var url in widget.note.attachmentURLS) {
      final imageData = await _getImageData(url);
      final image = pw.MemoryImage(imageData);
      imageWidgets.add(pw.Image(image, width: 100, height: 100, fit: pw.BoxFit.cover));
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(widget.note.title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(widget.note.content),
            pw.SizedBox(height: 20),
            if (widget.note.attachmentURLS.isNotEmpty)
              pw.Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: imageWidgets,
              ),
          ],
        ),
      ),
    );

    // Get the Downloads directory
    final directory = await getExternalStorageDirectory();
    final downloadsDir = Directory('${directory!.path}/Download');

    // Ensure the directory exists
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }

    // Save the PDF file in the Downloads folder
    final file = File("${downloadsDir.path}/${widget.note.title}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Notify the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to ${file.path}'),
        backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'content': _contentController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Last modified: ${widget.note.lastModified}',
            style: const TextStyle(color: Colors.grey, fontSize: 15)),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white, size: 30),
            onPressed: _exportNoteAsPdf,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
              ),
              const Divider(color: Colors.white54),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Write your note here...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              if (widget.note.attachmentURLS.isNotEmpty)
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: widget.note.attachmentURLS.map((url) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(url, width: 100, height: 100, fit: BoxFit.cover),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
                ),
                child: const Text('Edit Note', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
    );
  }
}
