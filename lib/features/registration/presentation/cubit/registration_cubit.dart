import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/utils/validators.dart';
import '../../data/registration_repository.dart';
import '../../domain/registration_form_data.dart';
import 'registration_state.dart';

class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit(this._repository) : super(const RegistrationState());

  final RegistrationRepository _repository;

  Map<String, String> _validate(RegistrationFormData data) {
    final errors = <String, String>{};

    if (data.firstName.trim().isEmpty) {
      errors[RegistrationField.firstName] = 'يرجى إدخال الاسم الأول';
    }
    if (data.fatherName.trim().isEmpty) {
      errors[RegistrationField.fatherName] = 'يرجى إدخال اسم الأب';
    }
    if (data.grandfatherName.trim().isEmpty) {
      errors[RegistrationField.grandfatherName] = 'يرجى إدخال اسم الجد';
    }

    final phoneError = Validators.phoneNumber(data.rawPhoneInput);
    if (phoneError != null) {
      errors[RegistrationField.phone] = phoneError;
    }

    if (data.governorate == null) {
      errors[RegistrationField.governorate] = 'يرجى اختيار المحافظة';
    }
    if (data.gender == null) {
      errors[RegistrationField.gender] = 'يرجى اختيار الجنس';
    }
    if (data.birthDate == null) {
      errors[RegistrationField.birthDate] = 'يرجى اختيار تاريخ الميلاد';
    }

    return errors;
  }

  Future<void> submit(RegistrationFormData data) async {
    final errors = _validate(data);
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(
          status: RegistrationStatus.failure,
          fieldErrors: errors,
          clearError: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: RegistrationStatus.submitting,
        fieldErrors: const {},
        clearError: true,
      ),
    );

    final result = await _repository.submitRegistration(data);
    switch (result) {
      case ApiSuccess<void>():
        emit(
          state.copyWith(
            status: RegistrationStatus.success,
            fieldErrors: const {},
            clearError: true,
          ),
        );
      case ApiFailure<void>(:final message):
        emit(
          state.copyWith(
            status: RegistrationStatus.failure,
            errorMessage: message,
            fieldErrors: const {},
          ),
        );
    }
  }
}
