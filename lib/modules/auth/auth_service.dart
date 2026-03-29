import 'dart:async';

class AuthService {

     Future<void> loginWithUsername(String username, String password) async {
  await Future.delayed(Duration(seconds: 1));

  print("Username Login Success");
  print("Username: $username");
}

  Future<void> loginWithGoogle() async {
    await Future.delayed(Duration(seconds: 1));
    print("Google Login Success");
  }

  Future<void> loginWithFacebook() async {
    await Future.delayed(Duration(seconds: 1));
    print("Facebook Login Success");
  }

  Future<void> loginWithTwitter() async {
    await Future.delayed(Duration(seconds: 1));
    print("Twitter Login Success");
  }

  Future<void> loginWithMicrosoft() async {
    await Future.delayed(Duration(seconds: 1));
    print("Microsoft Login Success");
  }

}