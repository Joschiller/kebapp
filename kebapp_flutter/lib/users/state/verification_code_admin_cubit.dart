import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kebapp_client/kebapp_client.dart';
import 'package:kebapp_flutter/main.dart';

sealed class VerificationCodeAdminCubitState {}

class VerificationCodeAdminCubitStateLoading
    extends VerificationCodeAdminCubitState {}

class VerificationCodeAdminCubitStateNoPermission
    extends VerificationCodeAdminCubitState {}

class VerificationCodeAdminCubitStateLoaded
    extends VerificationCodeAdminCubitState {
  final List<PendingVerification> verifications;

  VerificationCodeAdminCubitStateLoaded({required this.verifications});
}

class VerificationCodeAdminCubit
    extends Cubit<VerificationCodeAdminCubitState> {
  VerificationCodeAdminCubit()
      : super(VerificationCodeAdminCubitStateLoading()) {
    reload();
  }

  Future<void> reload() async {
    try {
      final verifications =
          await client.userVerification.getAllPendingVerifications();
      emit(
        VerificationCodeAdminCubitStateLoaded(
          verifications: verifications
            ..sort((a, b) => a.userName.compareTo(b.userName)),
        ),
      );
    } catch (e) {
      emit(VerificationCodeAdminCubitStateNoPermission());
    }
  }
}
