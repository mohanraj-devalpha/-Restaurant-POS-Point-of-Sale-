import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pos_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PosRepository repository;

  AuthBloc({required this.repository}) : super(const AuthState()) {
    on<AuthBusinessIdSubmitted>(_onBusinessIdSubmitted);
    on<AuthPasscodeDigitEntered>(_onPasscodeDigitEntered);
    on<AuthPasscodeDigitRemoved>(_onPasscodeDigitRemoved);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRememberMeToggled>(_onRememberMeToggled);
  }

  void _onBusinessIdSubmitted(
      AuthBusinessIdSubmitted event, Emitter<AuthState> emit) {
    if (event.businessId.trim().isEmpty) {
      emit(state.copyWith(error: 'Please enter a Business ID'));
      return;
    }
    emit(state.copyWith(
      businessId: event.businessId.trim(),
      page: AuthPage.passcode,
      error: null,
    ));
  }

  void _onPasscodeDigitEntered(
      AuthPasscodeDigitEntered event, Emitter<AuthState> emit) {
    if (state.passcode.length < 6) {
      emit(state.copyWith(
        passcode: state.passcode + event.digit,
        error: null,
      ));
    }
  }

  void _onPasscodeDigitRemoved(
      AuthPasscodeDigitRemoved event, Emitter<AuthState> emit) {
    if (state.passcode.isNotEmpty) {
      emit(state.copyWith(
        passcode: state.passcode.substring(0, state.passcode.length - 1),
        error: null,
      ));
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    if (state.passcode.length < 6) {
      emit(state.copyWith(error: 'Please enter full 6-digit passcode'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final success =
          await repository.authenticate(state.businessId, state.passcode);
      if (success) {
        emit(state.copyWith(
          page: AuthPage.authenticated,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          passcode: '',
          error: 'Invalid credentials. Please try again.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Authentication failed. Please try again.',
      ));
    }
  }

  void _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthState(page: AuthPage.welcome));
  }

  void _onRememberMeToggled(
      AuthRememberMeToggled event, Emitter<AuthState> emit) {
    emit(state.copyWith(rememberMe: event.value));
  }
}
