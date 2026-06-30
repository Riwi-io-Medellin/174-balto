import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String idNumber,
    required String idType,
    required String phone,
  }) async {
    emit(const AuthLoading());
    try {
      final tokens = await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        idNumber: idNumber,
        idType: idType,
        phone: phone,
      );
      emit(AuthAuthenticated(tokens));
    } on AuthFailure catch (e) {
      emit(AuthError(e.code, e.message));
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    emit(const AuthLoading());
    try {
      final tokens = await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      emit(AuthAuthenticated(tokens));
    } on AuthFailure catch (e) {
      emit(AuthError(e.code, e.message));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const AuthInitial());
  }

  Future<void> checkStoredAuth() async {
    final tokens = await _repository.restoreSession();
    if (tokens != null) {
      emit(AuthAuthenticated(tokens));
    } else {
      emit(const AuthInitial());
    }
  }

  void reset() => emit(const AuthInitial());
}
