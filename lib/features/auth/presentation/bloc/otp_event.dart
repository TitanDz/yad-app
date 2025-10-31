import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

class OtpVerifyEvent extends OtpEvent {
  final String email;
  final String code;

  const OtpVerifyEvent({
    required this.email,
    required this.code,
  });

  @override
  List<Object?> get props => [email, code];
}

class OtpResendEvent extends OtpEvent {
  final String email;

  const OtpResendEvent({required this.email});

  @override
  List<Object?> get props => [email];
}
