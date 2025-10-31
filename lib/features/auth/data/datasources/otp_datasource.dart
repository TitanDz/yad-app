/// Abstract interface for OTP operations
abstract class OtpDataSource {
  Future<void> verifyOtp({
    required String email,
    required String code,
  });

  Future<void> resendOtp({required String email});
}

/// Mock OTP implementation
class MockOtpDataSource implements OtpDataSource {
  /// Mock OTP code for testing: "123456"
  static const String _mockOtpCode = '123456';

  /// Simulated delay for OTP verification
  static const int apiDelayMs = 1500;

  @override
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: apiDelayMs));

    // Validate OTP code
    if (code != _mockOtpCode) {
      throw Exception('Invalid OTP code. Please try again.');
    }

    // OTP verified successfully
  }

  @override
  Future<void> resendOtp({required String email}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In real implementation, would trigger email send
    // For mock, just simulate success
  }
}
