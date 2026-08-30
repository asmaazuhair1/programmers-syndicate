import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/validators.dart';
import '../../data/auth_repository.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginInitial());

  final AuthRepository _authRepository;

  Future<void> submitPhoneNumber(String rawPhoneInput) async {
    final validationError = Validators.phoneNumber(rawPhoneInput);
    if (validationError != null) {
      emit(LoginFailure(validationError));
      return;
    }

    final localNumber = Validators.normalizePhoneNumber(rawPhoneInput);
    emit(const LoginSubmitting());

    final result = await _authRepository.requestLoginOtp(localNumber);
    switch (result) {
      case ApiSuccess<void>():
        emit(LoginOtpRequested(localNumber));
      case ApiFailure<void>(:final message):
        emit(LoginFailure(message));
    }
  }

  void reset() => emit(const LoginInitial());
}
