import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/client.dart';
import 'services/data_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/client_list_screen.dart';
import 'screens/add_client_screen.dart';
import 'screens/client_measures_screen.dart';
import 'screens/add_measurement_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_personal_data_screen.dart';
import 'screens/update_email_screen.dart';
import 'screens/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        home: FutureBuilder<bool>(
          future: _checkFirstLaunch(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSplashScreen();
            }
            
            final isFirstLaunch = snapshot.data ?? true;
            if (isFirstLaunch) {
              return WelcomeScreen();
            }
            
            return Consumer<DataService>(
              builder: (context, dataService, child) {
                if (dataService.isLoggedIn) {
                  return DashboardScreen();
                } else {
                  return LoginScreen();
                }
              },
            );
          },
        ),
        routes: {
          '/dashboard': (context) => DashboardScreen(),
          '/clients': (context) => ClientListScreen(),
          '/addClient': (context) => AddClientScreen(),
          '/profile': (context) => ProfileScreen(),
          '/register': (context) => RegisterScreen(),
          '/welcome': (context) => WelcomeScreen(),
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

  // Vérifier si c'est le premier lancement
  static Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    
    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false);
    }
    
    return isFirstLaunch;
  }

  // Écran de chargement initial
  static Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.straighten,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'TailorMate',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}