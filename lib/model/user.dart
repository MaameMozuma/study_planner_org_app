// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserProfile {
  final String username;
  final String email;
  final bool motivationalQuoteReminders;
  final bool studyTipReminders;
  final String uid;
  final String profilePicURL;
  final List<String> academic_details;
  UserProfile({
    required this.username,
    required this.email,
    required this.motivationalQuoteReminders,
    required this.studyTipReminders,
    required this.uid,
    required this.profilePicURL,
    required this.academic_details,
  });
  

  UserProfile copyWith({
    String? username,
    String? email,
    bool? motivationalQuoteReminders,
    bool? studyTipReminders,
    String? uid,
    String? profilePicURL,
    List<String>? academic_details,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
      motivationalQuoteReminders: motivationalQuoteReminders ?? this.motivationalQuoteReminders,
      studyTipReminders: studyTipReminders ?? this.studyTipReminders,
      uid: uid ?? this.uid,
      profilePicURL: profilePicURL ?? this.profilePicURL,
      academic_details: academic_details ?? this.academic_details,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'email': email,
      'motivationalQuoteReminders': motivationalQuoteReminders,
      'studyTipReminders': studyTipReminders,
      'uid': uid,
      'profilePicURL': profilePicURL,
      'academic_details': academic_details,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] as String,
      email: map['email'] as String,
      motivationalQuoteReminders: map['motivationalQuoteReminders'] as bool,
      studyTipReminders: map['studyTipReminders'] as bool,
      uid: map['uid'] as String,
      profilePicURL: map['profilePicURL'] as String,
      academic_details: List<String>.from((map['academic_details'] as List<String>),
    ), );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserProfile(username: $username, email: $email, motivationalQuoteReminders: $motivationalQuoteReminders, studyTipReminders: $studyTipReminders, uid: $uid, profilePicURL: $profilePicURL, academic_details: $academic_details)';
  }

  @override
  bool operator ==(covariant UserProfile other) {
    if (identical(this, other)) return true;
  
    return 
      other.username == username &&
      other.email == email &&
      other.motivationalQuoteReminders == motivationalQuoteReminders &&
      other.studyTipReminders == studyTipReminders &&
      other.uid == uid &&
      other.profilePicURL == profilePicURL &&
      listEquals(other.academic_details, academic_details);
  }

  @override
  int get hashCode {
    return username.hashCode ^
      email.hashCode ^
      motivationalQuoteReminders.hashCode ^
      studyTipReminders.hashCode ^
      uid.hashCode ^
      profilePicURL.hashCode ^
      academic_details.hashCode;
  }
}
