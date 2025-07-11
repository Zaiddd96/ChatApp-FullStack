import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticateUser() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      bool isDeviceSupported = await _auth.isDeviceSupported();
      if (canCheck && isDeviceSupported) {
        return await _auth.authenticate(
          localizedReason: 'Please authenticate to continue',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
          ),
        );
      }
      return false;
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }
}
