import 'dart:convert';

import 'package:study_master/model/note_model.dart';
import 'package:study_master/services/api_service.dart';

class NoteController {
  final ApiService _apiService = ApiService();

  Future<bool> createNote(Map<String, dynamic> data) async {
    final response = await _apiService.post('notes', data);

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<Note> getOneNote(String noteId) async {
    final response = await _apiService.get('notes/$noteId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Note.fromMap(data);
    } else {
      throw Exception(
          'Failed to load notes. Status code: ${response.statusCode}');
    }
  }

  Future<List<Note>> getAllNotes(String userId) async {
    final response = await _apiService.get('$userId/notes');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => Note.fromMap(e)).toList();
    } else {
      throw Exception(
          'Failed to load notes. Status code: ${response.statusCode}');
    }
  }

  Future<bool> updateNote(Map<String, dynamic> data, String noteId) async {
    final response =
        await _apiService.patch('notes/$noteId', data);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteNote(String noteId) async {
    final response = await _apiService.delete('notes/$noteId');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
