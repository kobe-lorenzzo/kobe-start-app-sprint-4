import 'package:fast_route/features/2_agenda/providers/scheduler_provider.dart';
import 'package:fast_route/services/places_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 

import 'core/config/firebase_options.dart';

import 'package:fast_route/features/1_auth/screens/login_screen.dart';
import 'features/1_auth/providers/auth_provider.dart';
import 'features/home_wrapper.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/geocoding_service.dart';
import 'services/location_service.dart';
import 'services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: "assets/.env");
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService().initNotification();

  } catch (e) {
    print("ERRO NA INICIALIZAÇÃO $e");
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create:(_) => FirestoreService()),
        Provider<GeocodingService>(create: (_) => GeocodingService()),
        Provider<PlaceService>(create: (_) => PlaceService()),
        Provider<LocationService>(create: (_) => LocationService()),
        Provider<NotificationService>(create: (_)=> NotificationService()),

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
            ),
        ),
        ChangeNotifierProvider<AgendaProvider>(
          create: (context) => AgendaProvider(
            context.read<FirestoreService>(),
            context.read<NotificationService>(),
          ),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAST ROUTE',
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);

        final restrictedScale = mediaQueryData.textScaleFactor.clamp(1.0, 1.5);

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaleFactor: restrictedScale,
          ),
          child: child!,
        );
      },

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const HomeWrapper();
        }

        return const LoginScreen();
      },
    );
  }
}
