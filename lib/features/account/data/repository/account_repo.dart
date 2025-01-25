import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../common_widget/error_message_widget.dart';
import '../../domain/repository/account_repo.dart';

class FirebaseRepo implements AccountRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
  Future<void> signInWithApple() {
    // TODO: implement signInWithApple
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithGooogle() {
    // TODO: implement signInWithGooogle
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signUpWithGoogle(context) async {
    GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      // Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

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
            'freeQuota': 1000,
            'usedQuota': 0,
            'subscriptionType': 'free',
            'lastReset': FieldValue.serverTimestamp(), // Use server timestamp
            'createdAt': FieldValue.serverTimestamp(),
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
  Future<void> signUpWithApple() {
    // TODO: implement signUpWithApple
    throw UnimplementedError();
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
  Future<void> resetPassword() {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }
}
