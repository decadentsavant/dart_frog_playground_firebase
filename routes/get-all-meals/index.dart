// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_frog/dart_frog.dart';
import '../../models/models.dart';
import '../../services/services.dart';

Future<Response> onRequest(RequestContext context) async {
  /// Getting the status of User Authentication
  final isAuthenticated = context.read<bool>();

  /// If User's JWT token is verified
  if (isAuthenticated) {
    try {
      /// Access the request from provided context
      final request = context.request;

      /// Get the FirebaseService client object
      final firebaseService = await context.read<Future<FirebaseService>>();

      /// Mongo: Get the MongoDBService client object from middlware
      final mongoDbService = await context.read<Future<MongoDBService>>();

      /// switch cases to handle multiple type of requests
      switch (request.method) {

        /// Handling GET request type
        case HttpMethod.get:

          // /// FB: Getting all the collection record in the from of Snapshot object
          // final snapshot = await firebaseService.realtimeDatabase
          //     .reference()
          //     .child('Meals')
          //     .once();

          // /// FB: converting snapshot object to Json object
          // final mapOfMaps =
          //     Map<String, dynamic>.from(snapshot.value as Map<String, dynamic>);

          // /// FB: Mapping Json objects to to Meals model and populating the List
          // final mealsList = mapOfMaps.values
          //     .map(
          //       (dynamic entry) => Meal.fromJson(entry as Map<String, dynamic>),
          //     )
          //     .toList();

          /// Open the Database to perform action
          await mongoDbService.openDb();

          /// Accessing the 'Meals' collection type in Database
          final mealsCollection = mongoDbService.database.collection('Meals');

          /// Getting all the collection record in the from of List of objects
          final mealsJson = await mealsCollection.find().toList();

          /// Mapping Json objects to to Meals model and populating the List
          final mealsList = mealsJson
              .map(
                (dynamic entry) => Meal.fromJson(entry as Map<String, dynamic>),
              )
              .toList();

          /// close the Database after performing the action
          await mongoDbService.closeDb();

          /// Generate the success response object containing message and List
          return Response.json(
            body: {
              'status': 200,
              'message': 'Fetched all meals records successfully',
              'data': mealsList,
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
    /// Generate a response for Unauthorized users
    return Response.json(
      statusCode: 401,
      body: {
        'status': 401,
        'message': 'Not authorized to perform this request',
      },
    );
  }
}
