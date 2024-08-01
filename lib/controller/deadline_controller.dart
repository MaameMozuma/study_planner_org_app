import 'dart:convert';

import 'package:study_master/model/deadline_model.dart';
import 'package:study_master/services/api_service.dart';

class DeadlineController {
  final ApiService _apiService = ApiService();

  Future<bool> createDeadline(Map<String, dynamic> data) async {
    final response = await _apiService.post('deadlines', data);

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<Deadline> getOneDeadline(String deadlineId) async {
    final response = await _apiService.get('deadlines/$deadlineId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Deadline.fromMap(data);
    } else {
      throw Exception(
          'Failed to load assignment deadlines. Status code: ${response.statusCode}');
    }
  }

  Future<List<Deadline>> getAllDeadlines(String userId) async {
    final response = await _apiService.get('$userId/deadlines');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      if (data.isEmpty) {
        return [];
      }
      return data.map((e) => Deadline.fromMap(e)).toList();
    } else {
      throw Exception(
          'Failed to load assignment deadlines. Status code: ${response.statusCode}');
    }
  }

  Future<bool> updateDealine(Map<String, dynamic> data, String deadlineId) async {
    final response =
        await _apiService.patch('deadlines/$deadlineId', data);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteDeadline(String deadlineId) async {
    final response = await _apiService.delete('deadlines/$deadlineId');

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
