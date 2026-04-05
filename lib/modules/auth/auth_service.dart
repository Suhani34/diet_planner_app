import 'dart:async';

class AuthService {
  Future<bool> loginWithUsername(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return username.trim().isNotEmpty && password.trim().length >= 6;
  }

  Future<void> loginWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    print("Google login placeholder");
  }

  Future<void> loginWithFacebook() async {
    await Future.delayed(const Duration(seconds: 1));
    print("Facebook login placeholder");
  }

  Future<void> loginWithTwitter() async {
    await Future.delayed(const Duration(seconds: 1));
    print("X login placeholder");
  }

  Future<void> loginWithMicrosoft() async {
    await Future.delayed(const Duration(seconds: 1));
    print("Microsoft login placeholder");
  }
}