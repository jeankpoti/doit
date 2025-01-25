import 'package:equatable/equatable.dart';

class AccountState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final bool isSignIn;
  final bool isSignOut;
  final String? errorMsg;

  const AccountState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isSignIn = false,
    this.isSignOut = false,
    this.errorMsg,
  });

  // Copy with helper for immutability
  AccountState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isSignIn,
    bool? isSignOut,
    String? errorMsg,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isSignIn: isSignIn ?? this.isSignIn,
      isSignOut: isSignOut ?? this.isSignOut,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        errorMsg,
        isSuccess,
        isSignIn,
        isSignOut,
      ];
}
