import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/validators.dart';
import '../../data/otp_repository.dart';
import '../../domain/otp_context.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit(
    this._otpRepository, {
    required this.localPhoneNumber,
    required this.context,
    int initialCountdownSeconds = 60,
  }) : super(OtpState(resendSecondsRemaining: initialCountdownSeconds)) {
    _startCountdown();
  }

  final OtpRepository _otpRepository;
  final String localPhoneNumber;
  final OtpContext context;

  Timer? _countdownTimer;

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendSecondsRemaining <= 1) {
        timer.cancel();
        emit(state.copyWith(resendSecondsRemaining: 0));
        return;
      }
      emit(
        state.copyWith(
          resendSecondsRemaining: state.resendSecondsRemaining - 1,
        ),
      );
    });
  }

  Future<void> submitCode(String code) async {
    final validationError = Validators.otpCode(code);
    if (validationError != null) {
      emit(
        state.copyWith(status: OtpStatus.error, errorMessage: validationError),
      );
      return;
    }

    emit(state.copyWith(status: OtpStatus.submitting, clearError: true));

    final result = await _otpRepository.verifyOtp(
      localPhoneNumber: localPhoneNumber,
      code: code,
      context: context,
    );

    switch (result) {
      case ApiSuccess<void>():
        emit(state.copyWith(status: OtpStatus.success, clearError: true));
      case ApiFailure<void>(:final message):
        emit(state.copyWith(status: OtpStatus.error, errorMessage: message));
    }
  }

  Future<void> resendCode() async {
    if (!state.canResend || state.status == OtpStatus.resending) return;

    emit(state.copyWith(status: OtpStatus.resending, clearError: true));
    final result = await _otpRepository.resendOtp(
      localPhoneNumber: localPhoneNumber,
      context: context,
    );

    switch (result) {
      case ApiSuccess<void>():
        emit(
          state.copyWith(status: OtpStatus.idle, resendSecondsRemaining: 60),
        );
        _startCountdown();
      case ApiFailure<void>(:final message):
        emit(state.copyWith(status: OtpStatus.error, errorMessage: message));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
