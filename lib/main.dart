import 'package:flutter/material.dart';
import 'package:younger_delivery/screens/dashboard_screen.dart';
import 'package:younger_delivery/screens/login_screen.dart';
import 'package:younger_delivery/screens/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:appwrite/appwrite.dart'; // Add this line for Appwrite

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Appwrite
  Client client = Client();
  client
      .setEndpoint('https://cloud.appwrite.io/v1')
      .setProject('64f7ef8e77ba79c0fb95')
      .setSelfSigned(status: true);
  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  final Client client;

  //add the contructor
  MyApp({required this.client});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/login': (context) => LoginScreen(),
        '/registration': (context) => RegistrationScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}

class Home extends StatelessWidget {
  // This constructor is already 'const'
  const Home();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GauxDeliver'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              child: Text('Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
