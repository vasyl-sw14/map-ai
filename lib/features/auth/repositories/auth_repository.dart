import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AuthRepository {
  Future<bool> checkAuthSession() async {
    try {
      final AuthSession session = await Amplify.Auth.fetchAuthSession();

      return session.isSignedIn;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await Amplify.Auth.signUp(
          username: email,
          password: password,
          options: SignUpOptions(
              userAttributes: {CognitoUserAttributeKey.email: email}));
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await Amplify.Auth.signIn(username: email, password: password);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }

  Future<bool> checkUserVerified() async {
    try {
      final List<AuthUserAttribute> attributes =
          await Amplify.Auth.fetchUserAttributes();

      print(attributes);

      for (AuthUserAttribute value in attributes) {
        if (value.userAttributeKey.key == 'email_verified' &&
            value.value == 'true') return true;
      }

      return false;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> verifyUser({required String email, required String code}) async {
    try {
      await Amplify.Auth.confirmSignUp(username: email, confirmationCode: code);
    } catch (_) {
      rethrow;
    }
  }
}
