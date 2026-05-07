import 'package:equatable/equatable.dart';

// ─── Auth Events ──────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthBusinessIdSubmitted extends AuthEvent {
  final String businessId;
  const AuthBusinessIdSubmitted(this.businessId);
  @override
  List<Object?> get props => [businessId];
}

class AuthPasscodeDigitEntered extends AuthEvent {
  final String digit;
  const AuthPasscodeDigitEntered(this.digit);
  @override
  List<Object?> get props => [digit];
}

class AuthPasscodeDigitRemoved extends AuthEvent {
  const AuthPasscodeDigitRemoved();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRememberMeToggled extends AuthEvent {
  final bool value;
  const AuthRememberMeToggled(this.value);
  @override
  List<Object?> get props => [value];
}
