import 'dart:async';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:map_ai/amplifyconfiguration.dart';
import 'package:map_ai/features/auth/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.repository) : super(const AuthState());

  final AuthRepository repository;

  void changeEmail(String value) {
    emit(state.copyWith(email: value));
  }

  void changePassword(String value) {
    emit(state.copyWith(password: value));
  }

  void changeCode(String value) {
    emit(state.copyWith(verificationCode: value));
  }

  Future<void> init() async {
    final AmplifyAuthCognito auth = AmplifyAuthCognito();

    await Amplify.addPlugins([auth]);

    await Amplify.configure(amplifyconfig);

    checkStatus();
  }

  Future<void> signUp() async {
    emit(state.copyWith(requestStatus: RequestStatus.loading));

    try {
      await repository.signUp(email: state.email, password: state.password);

      emit(state.copyWith(
          status: Status.unverified, requestStatus: RequestStatus.success));
    } catch (e) {
      if (e is AuthException) {
        emit(state.copyWith(errorMessage: e.message));
      } else {
        emit(state.copyWith(errorMessage: 'Unknown error'));
      }
      emit(
          state.copyWith(requestStatus: RequestStatus.error, errorMessage: ''));
    }
  }

  Future<void> signIn() async {
    emit(state.copyWith(requestStatus: RequestStatus.loading));

    try {
      await repository.signIn(email: state.email, password: state.password);

      emit(state.copyWith(
          status: Status.authenticated, requestStatus: RequestStatus.success));
    } catch (e) {
      print(e.toString());
      if (e is UserNotConfirmedException) {
        print('unverified');
        emit(state.copyWith(status: Status.unverified));
      } else if (e is AuthException) {
        emit(state.copyWith(errorMessage: e.message));
      } else {
        emit(state.copyWith(errorMessage: 'Unknown error'));
      }

      emit(
          state.copyWith(requestStatus: RequestStatus.error, errorMessage: ''));
    }
  }

  Future<void> checkStatus() async {
    final bool isSignedIn = await repository.checkAuthSession();

    if (isSignedIn) {
      final bool isVerified = await repository.checkUserVerified();

      if (!isVerified) {
        emit(state.copyWith(status: Status.unverified));

        return;
      }

      emit(state.copyWith(status: Status.authenticated));
    } else {
      emit(state.copyWith(status: Status.unauthenticated));
    }
  }

  Future<void> signOut() async {
    await repository.signOut();

    emit(state.copyWith(status: Status.unauthenticated));
  }

  Future<void> verifyUser() async {
    try {
      emit(state.copyWith(requestStatus: RequestStatus.loading));

      await repository.verifyUser(
          email: state.email, code: state.verificationCode);

      await repository.signIn(email: state.email, password: state.password);

      emit(state.copyWith(
          requestStatus: RequestStatus.success, status: Status.authenticated));
    } catch (e) {
      if (e is AuthException) {
        emit(state.copyWith(errorMessage: e.message));
      } else {
        emit(state.copyWith(errorMessage: 'Unknown error'));
      }

      emit(
          state.copyWith(requestStatus: RequestStatus.error, errorMessage: ''));
    }
  }
}
