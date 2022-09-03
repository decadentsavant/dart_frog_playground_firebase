//add-meals/index.dart
import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

Future<Response> onRequest(RequestContext context) async {
  /// Getting the status of User Authentication
  final isAuthenticated = context.read<bool>();

  /// If User's JWT token is verified
  if (isAuthenticated) {
    try {
      /// Access the request from provided context
      final request = context.request;

      /// Get the FirebaseService client object from middleware
      final firebaseService = await context.read<Future<FirebaseService>>();

      /// switch cases to handle multiple type of requests
      switch (request.method) {

        /// Handling POST request type
        case HttpMethod.post:

          /// Access the 'Meals' collection type in Database
          final usersRef =
              firebaseService.realtimeDatabase.reference().child('Meals');

          /// Get the Request body
          final requestBody = await request.body();

          /// Convert the Request body to Json object
          final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

          /// Convert the json object to Meals model
          final mealsData = Meal.fromJson(requestData);

          /// Add the data to the database
          final newMealRecord = usersRef.push();
          await newMealRecord.set(mealsData.toJson());

          /// Generate the success response object containing message and List
          return Response.json(
            body: {
              'status': 200,
              'message': 'New Meal added successfully',
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
    } catch (e) {
      /// Catch the Exception during execution
      /// Generate the response object for server errors
      return Response.json(
        statusCode: 500,
        body: {
          'status': 500,
          'message': 'Something went wrong. Internal server error.',
          'error': e.toString(),
        },
      );
    }
  } else {
    /// Generate a response object of Unauthorized users
    return Response.json(
      statusCode: 401,
      body: {
        'status': 401,
        'message': 'Not authorized to perform this request',
      },
    );
  }
}
