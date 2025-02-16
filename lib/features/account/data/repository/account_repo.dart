import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../common_widget/error_message_widget.dart';
import '../../domain/repository/account_repo.dart';

class FirebaseRepo implements AccountRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    context,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if email is verified
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        // _success = true;
      } else {
        // If email is not verified, sign out the user and show an error message
        await _auth.signOut();
        ErrorMessageWidget.showError(
          context,
          "Your email is not verified. Please check your inbox for the verification email.",
        );
        // _success =
        //     false; // Ensure success is false since sign-in should not proceed
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Show error message
        ErrorMessageWidget.showError(
          context,
          "No user found for that email.. Please try again.",
        );
      } else if (e.code == 'wrong-password') {
        // Show error message
        ErrorMessageWidget.showError(
          context,
          "Wrong password provided for that user. Please try again.",
        );
      } else if (e.code == 'invalid-credential') {
        ErrorMessageWidget.showError(
          context,
          "Email or password incorrect. Please try again.",
        );
      }
    } catch (e) {
      // Handle any other errors
    }
  }

  @override
  Future<void> signInWithApple(context) async {
    try {
      // Request an Apple ID Credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // webAuthenticationOptions: WebAuthenticationOptions(
        //   clientId: 'com.jeankpoti.studybuddy',
        //   redirectUri: Uri.parse(
        //     'https://humble-achieved-collision.glitch.me/callbacks/sign_in_with_apple',
        //   ),
        // ),
      );

      // Create an OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Use the credential to sign in with Firebase
      final authResult =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Get the current user
      final user = authResult.user;

      if (user != null) {
        // Check if this is a new user
        if (authResult.additionalUserInfo?.isNewUser ?? false) {
          ErrorMessageWidget.showError(
            context,
            "Account not found. Please sign up first!",
          );
        } else {
          // if (context.mounted) {
          //   //Navigate to the home screen
          //   // GoRouter.of(context).pushReplacementNamed(AppRoute.mainView.name);
          // }
        }
      }
    } catch (e) {
      ErrorMessageWidget.showError(
        context,
        "Unexpected error occurred!",
      );
    }
  }

  @override
  Future<void> signInWithGooogle(context) async {
    try {
      // Start Google Sign In flow
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Get Google authentication
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Check if user exists in Firestore before signing in
      final String email = googleSignInAccount.email;
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userQuery.docs.isEmpty) {
        // User doesn't exist in our database
        await _googleSignIn.signOut(); // Sign out from Google

        if (context.mounted) {
          ErrorMessageWidget.showError(
            context,
            "Account not found. Please sign up first!",
          );
        }
        return;
      }

      // Proceed with Firebase sign in if user exists
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Navigate to the home screen
        // GoRouter.of(context).pushReplacementNamed(AppRoute.mainView.name);
      }
    } on FirebaseAuthException {
      if (context.mounted) {
        ErrorMessageWidget.showError(
          context,
          "An authentication error occurred!",
        );
      }
    } catch (error) {
      // if (context.mounted) {
      //   ErrorMessageWidget.showError(
      //     context,
      //     "An unexpected error occurred!",
      //   );
      // }
    }
  }

  @override
  Future<UserCredential> signUpWithGoogle(context) async {
    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled');
      }

      // Obtain the auth details from the request
      try {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Check if user exists in Firestore before proceeding
        final userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: googleUser.email)
            .get();

        if (userQuery.docs.isNotEmpty) {
          if (context.mounted) {
            ErrorMessageWidget.showError(
                context, "You have already sign up. Please sign in!");
          }
          return Future.error(
              'Account already exists. Please sign in instead.');
        }

        // Once signed in, return the UserCredential

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);

        // Save the user's information to Firestore
        try {
          await _firestore
              .collection('users')
              .doc(userCredential.user?.uid)
              .set({
            'displayName': googleUser.displayName,
            'email': googleUser.email,
            'isSubscribed': false, // Free subscription
            'createdAt': DateTime.now(),
          });
        } catch (firestoreError) {
          // You might want to delete the Firebase Auth user if Firestore save fails
          await userCredential.user?.delete();
          throw Exception('Failed to save user data: $firestoreError');
        }

        // _signUpWithGoogleSuccess = true;
        return userCredential;
      } catch (authError) {
        throw Exception('Authentication failed: $authError');
      }
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  @override
  Future<UserCredential> signUpWithApple(context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Once signed in, return the UserCredential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Get the current user
      final user = userCredential.user;

      if (user != null) {
        // Check if this is a new user
        if (userCredential.additionalUserInfo?.isNewUser != null) {
          if (!userCredential.additionalUserInfo!.isNewUser) {
            if (context.mounted) {
              ErrorMessageWidget.showError(
                  context, "You have already signed up. Please sign in!");
            }
            return Future.error(
                'Account already exists. Please sign in instead.');
          } else {}
        }
      }

      // Save the user's information to Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'fullName':
            '${appleCredential.familyName} ${appleCredential.givenName}',
        'email': appleCredential.email,
        'isSubscribed': false, // Free subscription
        'createdAt': DateTime.now(),
      });

      // _signUpWithAppleSuccess = true;

      return userCredential;
    } catch (e) {
      // Handle error
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'This account exists with a different sign-in provider.';
            break;
          case 'invalid-credential':
            errorMessage =
                'The credential received is malformed or has expired.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'This operation is not allowed. Please enable it in the Firebase console.';
            break;
          case 'user-disabled':
            errorMessage =
                'This user has been disabled. Please contact support for help.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for the provided credentials.';
            break;
          case 'wrong-password':
            errorMessage =
                'The password is invalid or the user does not have a password.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid.';
            break;
          default:
            errorMessage = 'An unknown error occurred.';
        }
      } else {
        errorMessage = 'An unknown error occurred.';
      }

      // Show error message
      ErrorMessageWidget.showError(context, errorMessage);
    }
    return Future.error('An error occurred while signing up with Apple.');
  }

  @override
  Future<void> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    context,
  ) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After the user is created, we can add the username to the displayName field
      await userCredential.user?.updateProfile(displayName: fullName);

      // Create a new document for the user with the uid
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'fullName': fullName,
        'email': email,
        'isSubscribed': false, // Free subscription
        'createdAt': DateTime.now(),
      });

      // Check if the user is not null
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        // Send an email verification if the user is created successfully and email is not verified
        await user.sendEmailVerification();
        // Show a message or navigate the user to the next screen
        ErrorMessageWidget.showError(
          context,
          "Verification email has been sent. Please check your inbox.",
        );
      }

      // _success = true;

      // return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // Show error message
        ErrorMessageWidget.showError(
          context,
          "The password provided is too weak.",
        );
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        // Show error message
        ErrorMessageWidget.showError(
          context,
          "The account already exists for that email.",
        );
      }
    } catch (e) {
      // Show error message
      ErrorMessageWidget.showError(
        context,
        "An error occurred while signing up.",
      );
    }
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> resetPassword(context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Show a message to the user indicating that the email was sent

      ErrorMessageWidget.showError(
        context,
        "Password reset email will be sent to your email if the email exist in our system. Check your inbox.",
      );

      // _success = true;
    } on FirebaseAuthException catch (e) {
      // Handle errors, such as invalid email

      ErrorMessageWidget.showError(
        context,
        "Failed to send password reset email: ${e.message}",
      );
    } catch (e) {
      // Handle any other errors
      ErrorMessageWidget.showError(
        context,
        "An unexpected error occurred. Please try again.",
      );
    }
  }

  @override
  Future<void> deleteUserWithHisData(context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Delete data from all collections
        final collections = ['todos', 'users'];

        for (String collection in collections) {
          final querySnapshot = await FirebaseFirestore.instance
              .collection(collection)
              .where('userId', isEqualTo: user.uid)
              .get();

          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }
        }

        // Explicitly delete the user document from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();

        // Finally delete the authentication account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (context.mounted) {
          ErrorMessageWidget.showError(
            context,
            "Please sign out and sign in again to delete your account.",
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ErrorMessageWidget.showError(
          context,
          'Error deleting account. Please try again.',
        );
      }
    }
  }
}
