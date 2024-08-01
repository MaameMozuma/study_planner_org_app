import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_master/controller/auth_controller.dart';
import 'package:study_master/screens/sub-pages/edit_profile.dart';
import 'package:study_master/screens/sub-pages/landing.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class ViewUserprofile extends StatefulWidget {
  const ViewUserprofile({super.key});

  @override
  State<ViewUserprofile> createState() => _ViewUserprofileState();
}

class _ViewUserprofileState extends State<ViewUserprofile> {
  late User _user;
  late Future<Map<String, dynamic>?> _userProfile;
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _userProfile = _fetchUserProfile();
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    return _authController.getCurrentUser(_user.email!);
  }

  Future<void> _onRefresh() async {
    final userProfile = await _fetchUserProfile();
    setState(() {
      _userProfile = Future.value(userProfile);
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
          usernameController.text = userProfile['username'];
          emailController.text = userProfile['email'];
          var picURL = userProfile['profilePicURL'];
          return Scaffold(
            backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
            appBar: AppBar(
              backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
              title: const Text(
                'My Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 30),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(
                          picURL: userProfile['profilePicURL'],
                          username: userProfile['username'],
                          email: userProfile['email'],
                        ),
                      ),
                    );
                    if (result != null && result) {
                      _onRefresh();
                    }
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 40, 16.0, 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      ClipOval(
                        child: picURL.isNotEmpty
                            ? Image.network(
                                picURL,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey[600],
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey[600],
                                ),
                              ),
                      ),
                      const SizedBox(height: 50),
                      CustomTextField(
                        controller: usernameController,
                        labelText: 'Username',
                        hintText: 'Enter a valid username',
                        readOnly: true,
                        maxLenOfInput: 100,
                      ),
                      const SizedBox(height: 50),
                      CustomTextField(
                        controller: emailController,
                        labelText: 'Email',
                        hintText: 'Enter a valid email',
                        readOnly: true,
                        maxLenOfInput: 100,
                      ),
                      const SizedBox(height: 50),
                      CustomNormButton(
                        text: 'Log Out',
                        onPressed: () {
                          _authController.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LandingPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
