import 'package:firebase_core/firebase_core.dart';
import 'package:younger_delivery/firebase_options.dart'; // Replace with the correct path if necessary

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully.');
    } catch (error) {
      print('Failed to initialize Firebase: $error');
    }
  }
}
