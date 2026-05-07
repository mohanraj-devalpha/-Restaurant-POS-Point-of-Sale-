import 'package:equatable/equatable.dart';

// ─── Auth States ──────────────────────────────────────
enum AuthPage { welcome, businessId, passcode, authenticated }

class AuthState extends Equatable {
  final AuthPage page;
  final String businessId;
  final String passcode;
  final bool rememberMe;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.page = AuthPage.welcome,
    this.businessId = '',
    this.passcode = '',
    this.rememberMe = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthPage? page,
    String? businessId,
    String? passcode,
    bool? rememberMe,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      page: page ?? this.page,
      businessId: businessId ?? this.businessId,
      passcode: passcode ?? this.passcode,
      rememberMe: rememberMe ?? this.rememberMe,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props =>
      [page, businessId, passcode, rememberMe, isLoading, error];
}
