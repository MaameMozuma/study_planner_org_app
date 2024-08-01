import 'package:flutter/material.dart';
import 'package:study_master/controller/auth_controller.dart';
import 'package:study_master/screens/sub-pages/sign_up.dart';
import 'package:study_master/screens/widgets/bottom_nav_bar.dart';
import 'package:study_master/screens/widgets/custom_norm_btn.dart';
import 'package:study_master/screens/widgets/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ignore: unused_field
  String? _emailError;
  // ignore: unused_field
  String? _passwordError;

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _validateEmail();
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _validatePassword();
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _validateEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Email cannot be empty';
      });
      return;
    }
  }

  void _validatePassword() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Password cannot be empty';
        return;
      });
    } else {
      // Clear errors if both fields are non-empty
      setState(() {
        _passwordError = null;
      });
      return;
    }
  }

  Future<void> signIn(context) async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    setState(() {
      _validateEmail();
      _validatePassword();
    });

    if (_emailError == null && _passwordError == null) {
      //call login function
      var result = await _authController.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (result['message'] == 'No user found.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No user found.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (result['message'] ==
          'Wrong password provided for that user.') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Wrong password provided for that user.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (result['message'] == 'An error occurred') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Color.fromRGBO(255, 63, 23, 1),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomBottomNav(email: _emailController.text),
          ),
        );
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(29, 29, 29, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 140),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                hintText: 'Enter email address',
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                focusNode: _emailFocusNode,
                maxLenOfInput: 50,
              ),
              const SizedBox(height: 40),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                hintText: 'Enter password',
                errorText: _passwordError,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                focusNode: _passwordFocusNode,
                maxLenOfInput: 20,
              ),
              const SizedBox(height: 40),
              CustomNormButton(
                text: 'Log In',
                onPressed: () {
                  signIn(context);
                },
              ),
              const SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account yet?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()));
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Color.fromRGBO(255, 63, 23, 1),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
