import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:firebase_dart/firebase_dart.dart';

import '../../exceptions/firebase_exception_code.dart';
import '../../models/models.dart';
import '../../services/services.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    /// Access the request from provided context
    final request = context.request;

    /// FB: Get the FirebaseService client object from middleware
    final firebaseService = await context.read<Future<FirebaseService>>();

    /// Mongo: Get the MongoDBService client object from middlware
    final mongoDbServce = await context.read<Future<MongoDBService>>();

    /// Using switch cases to handle multiple type of requests
    switch (request.method) {

      /// Handling POST request type
      case HttpMethod.post:

        /// Get the Request body
        final requestBody = await request.body();

        /// Convert the Request body to Json object
        final requestData = jsonDecode(requestBody) as Map<String, dynamic>;

        /// Convert the json object to Users model
        final userData = AuthUser.fromJson(requestData);

        /// FB: Firebase Auth create User method
        await firebaseService.firebaseAuth.createUserWithEmailAndPassword(
          email: userData.email!,
          password: userData.password!,
        );

        /// FB: Access the 'Users' collection type in Firebase realtime database
        final usersRefFirebase =
            firebaseService.realtimeDatabase.reference().child('Users');

        /// FB: Get a Unique location in Firebase database
        final newUSerRecordFirebase = usersRefFirebase.push();

        /// FB: Add the User's data to Firebase database
        await newUSerRecordFirebase.set(userData.toJson());

        // Mongo: Open the Mongo database to perform action
        await mongoDbServce.openDb();

        /// Mongo: Access the "Users" collection type in MongoDb database
        final usersCollectionMongoDb =
            mongoDbServce.database.collection('Users');

        /// Mongo: Add user's data to MongoDb database
        await usersCollectionMongoDb.insertOne(userData.toJson());

        /// Mongo: Close the Mongo database after performing action
        await mongoDbServce.closeDb();

        /// Generate the success response object containing message
        return Response.json(
          body: {
            'status': 200,
            'message': 'User registered successfully',
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
    if (e.code == FirebaseExceptionCode.emailAlreadyInUse) {
      return Response.json(
        body: {
          'status': 200,
          'message': 'This email is already registered',
          'error': e.toString(),
        },
      );
    } else if (e.code == FirebaseExceptionCode.invalidEmail) {
      return Response.json(
        body: {
          'status': 200,
          'message': 'The email is not valid',
          'error': e.toString(),
        },
      );
    }

    /// Generic exception response object
    return Response.json(
      statusCode: 500,
      body: {
        'status': 500,
        'message': 'Something went wrong. Internal server error.',
        'error': e.toString(),
      },
    );
  }
}
