/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

// import '../../data/models/isar_todo.dart';

abstract class AccountRepo {
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    context,
  );
  Future<void> signInWithGooogle();
  Future<void> signInWithApple();
  Future<void> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    context,
  );
  Future<void> signUpWithGoogle(context);
  Future<void> signUpWithApple();
  Future<void> signOut();
  Future<void> resetPassword();
}

/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
