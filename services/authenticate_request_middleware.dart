import 'package:dart_frog/dart_frog.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../config/configurations.dart';

Middleware authenticateRequest() {
  return provider<bool>((context) {
    final request = context.request;
    // retrieve login information and auth type
    final headers = request.headers as Map<String, String>;
    final authData = headers['Authorization'];

    // if auth type is JWT token type, verify token and
    // using dependency injection return TRUE for verified
    // FALSE for unverified
    try {
      final receivedToken = authData!.trim();
      // return true if verified token
      verifyJwtHS256Signature(
        receivedToken,
        Configurations.secretKeyJwt,
      );
      return true;
    } catch (e) {
      return false;
    }
  });
}
