import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final List<String> _attachmentURLs = [];
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Loading state

  final _formKey = GlobalKey<FormState>(); // Form key

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _uploadImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      for (File image in _images) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        Reference ref = FirebaseStorage.instance.ref().child('images/$fileName');
        await ref.putFile(image);
        String downloadURL = await ref.getDownloadURL();
        _attachmentURLs.add(downloadURL);
      }
    } catch (e) {
      print('Failed to upload images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      await _uploadImages();
      var data = {
        'title': _titleController.text,
        'content': _contentController.text,
        'attachmentURLS': _attachmentURLs,
      };
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
              if (_isLoading) // Show loading indicator while uploading
                const Center(child: CircularProgressIndicator()),
              Wrap(
                children: _images.map((image) => Image.file(image, width: 100, height: 100)).toList(),
              ),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
                ),
                child: const Text('Add Image', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _saveNote,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: const Color.fromRGBO(255, 63, 23, 1),
                ),
                child: const Text('Save Note', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
    );
  }
}
