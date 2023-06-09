part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final String email;
  final String password;
  final String verificationCode;
  final Status status;
  final RequestStatus requestStatus;
  final String? errorMessage;

  const AuthState(
      {this.email = '',
      this.password = '',
      this.verificationCode = '',
      this.status = Status.initial,
      this.requestStatus = RequestStatus.initial,
      this.errorMessage});

  @override
  List<Object?> get props =>
      [email, password, verificationCode, status, errorMessage, requestStatus];

  AuthState copyWith(
      {String? email,
      String? password,
      String? verificationCode,
      Status? status,
      RequestStatus? requestStatus,
      String? errorMessage}) {
    return AuthState(
        email: email ?? this.email,
        password: password ?? this.password,
        status: status ?? this.status,
        requestStatus: requestStatus ?? this.requestStatus,
        verificationCode: verificationCode ?? this.verificationCode,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

enum Status { initial, authenticated, unauthenticated, unverified }

enum RequestStatus { initial, loading, success, error }
