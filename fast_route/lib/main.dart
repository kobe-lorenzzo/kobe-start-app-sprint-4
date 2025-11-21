import 'package:fast_route/features/1_auth/providers/scheduler_provider.dart';
import 'package:fast_route/features/1_auth/screens/scheduler_list_screen.dart';
import 'package:fast_route/services/places_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; 

import 'core/config/firebase_options.dart';

import 'package:fast_route/features/1_auth/screens/login_screen.dart';
import 'features/1_auth/providers/auth_provider.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/geocoding_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    /*await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider.debug(), 
        androidProvider: AndroidProvider.debug, 
        appleProvider: AppleProvider.debug,
      );*/

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

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<FirestoreService>(),
            ),
        ),
        ChangeNotifierProvider<AgendaProvider>(
          create: (context) => AgendaProvider(
            context.read<FirestoreService>(),
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

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // O StreamBuilder fica "ouvindo" o Firebase Auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Se estiver esperando a resposta do Firebase...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Se tem dados (tem usuário logado)...
        if (snapshot.hasData) {
          return const AgendaListScreen(); // ... Vai pra Casa!
        }

        // 3. Se não tem dados (não está logado)...
        return const LoginScreen(); // ... Vai pro Login!
      },
    );
  }
}
