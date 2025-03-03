/*
 TO DO CUBIT - Simple sate management

 Each cubit is a list of todos
*/

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../todo/data/repository/hybrid_todo_repo.dart';
import '../domain/repository/account_repo.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  // Reference  todo repo
  final AccountRepo accountRepo;
  final HybridTodoRepo hybridTodoRepo; // <--- We have access to set isSignedIn

  AccountCubit(
    this.accountRepo,
    this.hybridTodoRepo,
  ) : super(const AccountState());

  // signInWithApple
  Future<void> signInWithApple(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signInWithApple(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isSignIn: true,
        errorMsg: null,
      ));

      // If successful:
      // hybridTodoRepo.isSignedIn = true; // <--- Turn on remote sync
      await hybridTodoRepo.syncTodosIfNeeded(); // optional immediate sync
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // signInWithGooogle
  Future<void> signInWithGooogle(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signInWithGooogle(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isSignIn: true,
        errorMsg: null,
      ));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

// signUpWithEmailAndPassword
  Future<void> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    context,
  ) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithEmailAndPassword(
        fullName,
        email,
        password,
        context,
      );

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(isLoading: false, errorMsg: null));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // signInWithEmailAndPassword
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    context,
  ) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signInWithEmailAndPassword(
        email,
        password,
        context,
      );

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
          isLoading: false, isSuccess: true, isSignIn: true, errorMsg: null));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

// signOut
  Future<void> signOut() async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signOut();

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isSignIn: false,
        isSignOut: true,
        errorMsg: null,
      ));

      resetSignOut();
      // hybridTodoRepo.isSignedIn = false;
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(
        state.copyWith(
          isLoading: false,
          isSignIn: false,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  void resetSignOut() {
    emit(state.copyWith(isSignOut: false));
  }

  // signUpWithGoogle
  Future<void> signUpWithGoogle(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithGoogle(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isSignIn: true,
        errorMsg: null,
      ));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // signUpWithApple
  Future<void> signUpWithApple(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithApple(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        isSignIn: true,
        errorMsg: null,
      ));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // resetPassword
  Future<void> resetPassword(context, email) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.resetPassword(context, email);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMsg: null,
      ));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> deleteUserWithHisData(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.deleteUserWithHisData(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMsg: null,
      ));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  bool checkSignInStatus() {
    return state.isSignIn;
  }
}
