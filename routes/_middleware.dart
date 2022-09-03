import 'package:dart_frog/dart_frog.dart';

import '../services/services.dart';

final firebaseService = FirebaseService();
final mongoDBService = MongoDBService();

Handler middleware(Handler handler) {
  return handler
      .use(
        provider<Future<FirebaseService>>((_) async {
          await firebaseService.init();
          return firebaseService;
        }),
      )
      .use(
        (handler) => handler.use(authenticateRequest()),
      )
      .use(
        provider<Future<MongoDBService>>(
          (_) async {
            await mongoDBService.init();
            return mongoDBService;
          },
        ),
      );
}
