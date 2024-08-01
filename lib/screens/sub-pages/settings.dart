import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/auth_controller.dart';
import 'package:study_master/screens/sub-pages/enable_notifications.dart';
import 'package:study_master/screens/sub-pages/view_userprofile.dart';

class CSettings extends StatefulWidget {
  const CSettings({super.key});

  @override
  State<CSettings> createState() => _SettingsState();
}

class _SettingsState extends State<CSettings> {
  final AuthController _authController = AuthController();
  late Future<Map<String, dynamic>?> _userProfile;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _userProfile = _authController.getCurrentUser(_user.email!);
  }

  Future<void> _refreshUserProfile() async {
    setState(() {
      _userProfile = _authController.getCurrentUser(_user.email!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, dynamic> userProfile = snapshot.data!;
          var motivationalQuoteReminders =
              userProfile['motivationalQuoteReminders'];
          var studyTipsReminders = userProfile['studyTipReminders'];
          return Scaffold(
            backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
            appBar: AppBar(
              title: const Text('Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _refreshUserProfile,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 40, 16.0, 0),
                child: ListView(
                  children: [
                    const Divider(
                      thickness: 2,
                      color: Color.fromARGB(255, 89, 88, 88),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications, color: Colors.white),
                      title: const Text('Notifications',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                      onTap: () {
                        // Navigate to a different page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EnableNotifications(
                                    isMotivationalQuote:
                                        motivationalQuoteReminders,
                                    isStudyTips: studyTipsReminders,
                                  )),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 2,
                      color: Color.fromARGB(255, 89, 88, 88),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text('Account',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                      onTap: () {
                        // Navigate to a different page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViewUserprofile()),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 2,
                      color: Color.fromARGB(255, 89, 88, 88),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }
}
