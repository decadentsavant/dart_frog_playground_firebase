import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:firebase_dart/firebase_dart.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

import '../../config/configurations.dart';
import '../../exceptions/firebase_exception_code.dart';
import '../../models/models.dart';
import '../../services/services.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    /// Access the request from provided context
    final request = context.request;

    /// Get the FirebaseService client object from middleware
    final firebaseService = await context.read<Future<FirebaseService>>();

    /// Using switch cases to handle multiple type of requests
    switch (request.method) {
      case HttpMethod.post:

        /// Get the Request body
        final requestBody = await request.body();

        /// Convert the Request body to Json object
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        /// Convert the json object to Users model
        final userData = AuthUser.fromJson(requestData);

        /// Firebase Auth sign in method
        final credential =
            await firebaseService.firebaseAuth.signInWithEmailAndPassword(
          email: userData.email!,
          password: userData.password!,
        );

        /// Create a new JWT token of Logged In user
        final token = issueJWTToken(credential.user!.uid);

        /// Generate the success response object containing message
        return Response.json(
          body: {
            'status': 200,
            'message': 'User logged in successfully',
            'token': token,
          },
        );
      // ignore: no_default_cases
      default:

        /// Handle all other type of requests
        /// Generate a response for invalid requests
        return Response.json(
          statusCode: 404,
          body: {
            'status': 404,
            'message': 'invalid request',
          },
        );
    }
  } on FirebaseException catch (e) {
    /// Handling exceptions from firebase methods
    /// Generate custom response object for each type of exception
    if (e.code == FirebaseExceptionCode.userNotFound) {
      return Response.json(
        body: {
          'status': 200,
          'message': 'No user found for this email',
          'error': e.message,
        },
      );
    } else if (e.code == FirebaseExceptionCode.wrongPassword) {
      return Response.json(
        body: {
          'status': 200,
          'message': 'Password is not correct',
          'error': e.message,
        },
      );
    }

    /// Generic exception response object
    return Response.json(
      statusCode: 500,
      body: {
        'status': 500,
        'message': 'Something went wrong. Internal server error.',
        'error': e.message,
      },
    );
  }
}

/// method to create JWT token
String issueJWTToken(String usedId) {
  /// create JwtClaim object
  final claimSet = JwtClaim(
    subject: usedId,
    issuer: 'sideGuide',
    otherClaims: <String, dynamic>{
      'typ': 'authnresponse',
    },
    maxAge: const Duration(hours: 24),
  );

  /// issue token with JwtClaim and user Id
  final token = issueJwtHS256(claimSet, Configurations.secretKeyJwt);
  return token;
}
