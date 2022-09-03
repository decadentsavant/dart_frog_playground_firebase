import 'package:dart_frog/dart_frog.dart';
import '../../models/models.dart';
import '../../services/firebase_service.dart';

Future<Response> onRequest(RequestContext context) async {
  /// Getting the status of User Authentication from middleware
  final isAuthenticated = context.read<bool>();

  if (isAuthenticated) {
    try {
      /// Access the request from provided context
      final request = context.request;

      /// Get the FirebaseService client object
      final firebaseService = await context.read<Future<FirebaseService>>();

      switch (request.method) {
        // Hande GET request type
        case HttpMethod.get:
          final params = request.uri.queryParameters;

          /// validate the parameters
          if (params.isNotEmpty) {
            final category = params['category'];
            if (category != null) {
              final ref =
                  firebaseService.realtimeDatabase.reference().child('Meals');
              var mealsList = <Meal>[];

              /// Applying search query using specific attribute i.e. Category
              final data =
                  await ref.orderByChild('category').equalTo(category).once();

              /// If no record found against the query
              if (data.value == null) {
                return Response.json(
                  body: {
                    'status': 200,
                    'message': 'Fetched all meals records successfully',
                    'data': mealsList,
                  },
                );
              }

              /// Convert DataSnapshot object to Json object
              final mapOfMaps =
                  Map<String, dynamic>.from(data.value as Map<String, dynamic>);

              /// Mapping Json objects to Meals model and populating the List
              mealsList = mapOfMaps.values
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
