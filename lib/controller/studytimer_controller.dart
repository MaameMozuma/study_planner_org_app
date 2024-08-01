import 'dart:async';
import 'dart:convert';
import 'package:study_master/model/studytimer_model.dart';
import 'package:study_master/services/api_service.dart';

class StudytimerController {
  final ApiService _apiService = ApiService();

  Future<bool> createStudytimer(Map<String, dynamic> data) async {
    final response = await _apiService.post('studyTimers', data);

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<Studytimer> getOneStudytimer(String studytimerId) async {
    final response = await _apiService.get('studyTimers/$studytimerId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Studytimer.fromMap(data);
    } else {
      throw Exception(
          'Failed to load study timers. Status code: ${response.statusCode}');
    }
  }

  Future<List<Studytimer>> getAllStudytimers(String userId) async {
    final response = await _apiService.get('$userId/studyTimers');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => Studytimer.fromMap(e)).toList();
    } else {
      throw Exception(
          'Failed to load study timers. Status code: ${response.statusCode}');
    }
  }

  Future<bool> updateStudytimer(Studytimer data, String studytimerId) async {
    final response =
        await _apiService.patch('studyTimers/$studytimerId', data.toJson());

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteStudytimer(String studytimerId) async {
    final response = await _apiService.delete('studyTimers/$studytimerId');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
