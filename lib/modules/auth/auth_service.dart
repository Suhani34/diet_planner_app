//auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static bool _googleInitialized = false;

  // Put your WEB client ID here.
  // google-services.json -> oauth_client -> client_type: 3 -> client_id
  static const String _googleServerClientId =
      "209777607736-mld8ps7vc3ntncpl35mm5ng95n231igq.apps.googleusercontent.com";

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> loginWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    if (!_googleInitialized) {
      await googleSignIn.initialize(
        serverClientId: _googleServerClientId,
      );
      _googleInitialized = true;
    }

    final GoogleSignInAccount googleUser =
        await googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception("Google ID token missing. Check Web client ID and SHA-1.");
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> loginWithFacebook() async {
    await FacebookAuth.instance.logOut();

    final result = await FacebookAuth.instance.login(
      permissions: const ["email", "public_profile"],
    );

    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw Exception(result.message ?? "Facebook login failed");
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> loginWithX() async {
    final provider = OAuthProvider("twitter.com");
    return await _auth.signInWithProvider(provider);
  }

  Future<UserCredential> loginWithMicrosoft() async {
    final provider = OAuthProvider("microsoft.com");

    provider.setCustomParameters({
      "prompt": "select_account",
    });

    provider.addScope("openid");
    provider.addScope("profile");
    provider.addScope("email");

    return await _auth.signInWithProvider(provider);
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}

    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}