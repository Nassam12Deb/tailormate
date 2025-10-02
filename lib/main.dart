import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/data_service.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataService()),
      ],
      child: MaterialApp(
        title: 'TailorMate',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'Roboto',
        ),
        home: AuthWrapper(),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/clients': (context) => ClientListScreen(),
          '/addClient': (context) => AddClientScreen(),
          '/profile': (context) => ProfileScreen(),
          '/register': (context) => RegisterScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/clientMeasures') {
            final client = settings.arguments as Client;
            return MaterialPageRoute(
              builder: (context) => ClientMeasuresScreen(client: client),
            );
          } else if (settings.name == '/addMeasurement') {
            final client = settings.arguments as Client;
            return MaterialPageRoute(
              builder: (context) => AddMeasurementScreen(client: client),
            );
          }
          return null;
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseService.auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Utilisateur connecté
          return DashboardScreen();
        } else {
          // Utilisateur non connecté
          return LoginScreen();
        }
      },
    );
  }
}