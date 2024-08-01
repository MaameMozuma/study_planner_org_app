import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class EnableNotifications extends StatefulWidget {
  final bool isMotivationalQuote;
  final bool isStudyTips;

  const EnableNotifications({super.key, this.isMotivationalQuote = false, this.isStudyTips = false});

  @override
  State<EnableNotifications> createState() => _EnableNotificationsState();
}

class _EnableNotificationsState extends State<EnableNotifications> {
  late bool _motivationalQuote;
  late bool _studyTips;
  late User user;

  @override
  void initState() {
    super.initState();
    _motivationalQuote = widget.isMotivationalQuote;
    _studyTips = widget.isStudyTips;
    user = FirebaseAuth.instance.currentUser!;
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      // Fetch and store the FCM token here
      String? fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        // Update the Firestore document with the FCM token
        await FirebaseFirestore.instance.collection('users').doc(user.email).update({
          'fcmToken': fcmToken,
        });
      }
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _updateNotificationPreferences() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'motivationalQuoteReminders': _motivationalQuote,
        'studyTipReminders': _studyTips,
      });
      print('Preferences updated successfully');
    } catch (e) {
      print('Failed to update preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
        child: Column(
          children: [
            const Divider(
              thickness: 2,
              color: Color.fromARGB(255, 89, 88, 88),
            ),
            SwitchListTile(
              activeColor: const Color.fromRGBO(255, 63, 23, 1),
              title: const Text('Receive notifications for motivational quote', style: TextStyle(color: Colors.white)),
              value: _motivationalQuote,
              onChanged: (bool value) {
                setState(() {
                  _motivationalQuote = value;
                });
                _updateNotificationPreferences(); // Call to update Firestore
              },
            ),
            const Divider(
              thickness: 2,
              color: Color.fromARGB(255, 89, 88, 88),
            ),
            SwitchListTile(
              activeColor: const Color.fromRGBO(255, 63, 23, 1),
              title: const Text('Receive notifications for study tips', style: TextStyle(color: Colors.white)),
              value: _studyTips,
              onChanged: (bool value) {
                setState(() {
                  _studyTips = value;
                });
                _updateNotificationPreferences(); // Call to update Firestore
              },
            ),
            const Divider(
              thickness: 2,
              color: Color.fromARGB(255, 89, 88, 88),
            ),
          ],
        ),
      ),
    );
  }
}
