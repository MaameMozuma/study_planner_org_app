import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_master/model/studyhour_model.dart';
import 'package:study_master/services/api_service.dart';

class StudyhourController {
  final ApiService _apiService = ApiService();

  Future<bool> createStudyHour(Map<String, dynamic> data) async {
    final response = await _apiService.post('studyHours', data);

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<StudyHour> getOneStudyhour(String studyhourId) async {
    final response = await _apiService.get('studyHours/$studyhourId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return StudyHour.fromMap(data);
    } else {
      throw Exception(
          'Failed to load study hours. Status code: ${response.statusCode}');
    }
  }

  Stream<List<StudyHour>> getStudyHoursStream(String email) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('studyHours')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudyHour.fromDocument(doc))
            .toList());
  }

  Future<List<StudyHour>> getAllStudyhours(String userId) async {
    final response = await _apiService.get('$userId/studyHours');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => StudyHour.fromMap(e)).toList();
    } else {
      throw Exception(
          'Failed to load study hours. Status code: ${response.statusCode}');
    }
  }

  Future<bool> updateStudyhour(Map<String, dynamic> data, String studyhourId) async {
    final response =
        await _apiService.patch('studyHours/$studyhourId', data);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteStudyhour(String studyhourId) async {
    final response = await _apiService.delete('studyHours/$studyhourId');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  getAllStudytimers(String email) {}
}
