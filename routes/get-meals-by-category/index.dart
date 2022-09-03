import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../../models/models.dart';
import '../../services/services.dart';

Future<Response> onRequest(RequestContext context) async {
  /// Getting the status of User Authentication from middleware
  final isAuthenticated = context.read<bool>();

  if (isAuthenticated) {
    try {
      /// Access the request from provided context
      final request = context.request;

      /// Get the FirebaseService client object
      final firebaseService = await context.read<Future<FirebaseService>>();

            /// Mongo: Get the MongoDBService client object from middlware
      final mongoDbService = await context.read<Future<MongoDBService>>();

      switch (request.method) {
        // Hande GET request type
        case HttpMethod.get:
          final params = request.uri.queryParameters;

          // /// validate the parameters
          // if (params.isNotEmpty) {
          //   final category = params['category'];
          //   if (category != null) {
          //     final ref =
          //         firebaseService.realtimeDatabase.reference().child('Meals');
          //     var mealsList = <Meal>[];

          //     /// Applying search query using specific attribute i.e. Category
          //     final data =
          //         await ref.orderByChild('category').equalTo(category).once();

          //     /// If no record found against the query
          //     if (data.value == null) {
          //       return Response.json(
          //         body: {
          //           'status': 200,
          //           'message': 'Fetched all meals records successfully',
          //           'data': mealsList,
          //         },
          //       );
          //     }

          //     /// Convert DataSnapshot object to Json object
          //     final mapOfMaps =
          //         Map<String, dynamic>.from(data.value as Map<String, dynamic>);

          //     /// Mapping Json objects to Meals model and populating the List
          //     mealsList = mapOfMaps.values
          //         .map(
          //           (dynamic entry) =>
          //               Meal.fromJson(entry as Map<String, dynamic>),
          //         )
          //         .toList();

               /// Open the Database to perform action
         await mongoDbService.openDb();

         /// Accessing the 'Meals' collection type in Database
         final mealsCollection = mongoDbService.database.collection('Meals');

         /// validating the parameters
         if (params.isNotEmpty) {
           final category = params['category'];
           if (category != null) {
             var mealsList = <Meal>[];

             /// Applying search query using specific attribute i.e. Category
             final record = await mealsCollection
                 .find(
                   where.eq('category', category),
                 )
                 .toList();

             /// close the Database after performing the action
             await mongoDbService.closeDb();

             /// If no record found against the query
              if (record.isEmpty) {
                return Response.json(
                  body: {
                    'status': 201,
                    'message': 'Fetched all meals records successfully',
                    'data': mealsList,
                  },
                );
              }

              /// Mapping Json objects to to Meals model and populating the List
              mealsList = record
                  .map(
                    (dynamic entry) =>
                        Meal.fromJson(entry as Map<String, dynamic>),
                  )
                  .toList();


              return Response.json(
                body: {
                  'status': 200,
                  'message': 'Fetched all meals records successfully',
                  'data': mealsList,
                },
              );
            }
          }

          return Response.json(
            body: {
              'status': 200,
              'message': 'Invalid request. No parameters found',
            },
          );
        default:

          /// Handle all other type of requests
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
