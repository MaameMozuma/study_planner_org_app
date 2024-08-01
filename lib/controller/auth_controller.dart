import 'package:study_master/services/auth.dart';

class AuthController {
  final AuthService _authService = AuthService();
  Future<String?> checkPasswordSimilarity(
      String password, String confirmPassword) async {
    if (password == confirmPassword) {
      return null;
    }
    return 'passwords do not match';
  }

  Future<bool> isValidPassword(String password) async {
    return await _authService.isValidPassword(password);
  }

  Future<String> checkEmail(String email) async {
    int emailExists = await _authService.emailExists(email);
    if (emailExists == 0) {
      return 'does not exist';
    } else if (emailExists == 1) {
      return 'email exists';
    } else {
      return 'error';
    }
  }

  Future<bool> isEmailValid(String email) async {
    return await _authService.isValidEmail(email);
  }

  Future<String> checkUsername(String username) async {
    int usernameExists = await _authService.usernameExists(username);
    if (usernameExists == 0) {
      return 'does not exist';
    } else if (usernameExists == 1) {
      {
        return 'username exists';
      }
    } else {
      return 'error';
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser(String email) async {
    return await _authService.getUserInfo(email);
  }

  Future<bool> editUser(String email, Map<String, dynamic> updatedData) async{
    return await _authService.editUserInfo(email, updatedData);
  }

  Future<bool> isEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  Future<Map<String, String>> registerWithEmailAndPassword(
      String email, String password) async {
    return await _authService.registerWithEmailAndPassword(email, password);
  }

  Future<Map<String, String>> signInWithEmailAndPassword(String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

  void saveUserInfo(String uid, String email, password, username, token) async {
    await _authService.saveUserInfo(uid, email, password, username, token);
  }

  void sendEmailVerification() async {
    await _authService.emailVerification();
  }

  void setTimerForAutoRedirect() async {}

  void manullayCheckEmailVerificationStatus() async {}

  void signOut() {
    _authService.signOut();
  }
}
