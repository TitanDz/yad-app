import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_event.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_state.dart';
import 'package:yad_app/features/auth/data/datasources/otp_datasource.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  final OtpDataSource otpDataSource;

  OtpBloc({required this.otpDataSource}) : super(const OtpInitial()) {
    on<OtpVerifyEvent>(_onOtpVerify);
    on<OtpResendEvent>(_onOtpResend);
  }

  Future<void> _onOtpVerify(
    OtpVerifyEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    try {
      await otpDataSource.verifyOtp(
        email: event.email,
        code: event.code,
      );
      emit(const OtpVerified());
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }

  Future<void> _onOtpResend(
    OtpResendEvent event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpLoading());
    try {
      await otpDataSource.resendOtp(email: event.email);
      emit(const OtpResendSuccess());
    } catch (e) {
      emit(OtpFailure(e.toString()));
    }
  }
}
