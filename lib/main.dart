import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/client.dart';
import 'services/data_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/client_list_screen.dart';
import 'screens/add_client_screen.dart';
import 'screens/client_measures_screen.dart';
import 'screens/add_measurement_screen.dart';
import 'screens/profile_screen.dart';

void main() {
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
        home: LoginScreen(),
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