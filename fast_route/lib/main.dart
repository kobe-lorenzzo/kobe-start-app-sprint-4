import 'package:fast_route/features/1_auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'services/auth_service.dart';
import 'features/1_auth/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'), 
        
        androidProvider: AndroidProvider.debug, 
        
        appleProvider: AppleProvider.debug, 
      );
      print("✅ App Check ativado em modo de depuração.");
      print("🔥 PROCURE O TOKEN DE DEPURAÇÃO NO CONSOLE ABAIXO! 🔥");

  } catch (e) {
    print("❌ ERRO NA INICIALIZAÇÃO (Firebase ou AppCheck):");
    print(e.toString());
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService()
          ),

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>()
            ),
        ),

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

      home: const LoginScreen(),
    );
  }
}
