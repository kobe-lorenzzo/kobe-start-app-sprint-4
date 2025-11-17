import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final Color textColor = const Color.fromARGB(255, 123, 74, 255);
  final Color textColorLight = const Color.fromARGB(255, 166, 134, 255);
  final Color backgroundColor = const Color.fromARGB(255, 48, 48, 48);
  final Color backgroundColorLight = const Color.fromARGB(255, 175, 175, 175);

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()){
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      bool success = await authProvider.register(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conta criada com sucesso! (Usuário: ${authProvider.user!.email})")),
        );
        // Volta para a tela de login
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar: $e")),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar:  AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      labelStyle: TextStyle(color: textColor),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColorLight),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || !value.contains("@"))
                      ? "Por favor, insira um e-mail válido"
                      : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color:Colors.white),
                    decoration: InputDecoration(
                      labelText: "Senha (mín. 6 caracteres)",
                      labelStyle: TextStyle(color: textColor),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColorLight),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) => (value == null || value.length < 6)
                        ? "A senha deve ter pelo menos 6 caracteres."
                        : null,
                  ),
                  const SizedBox(height: 20),

                  if (authProvider.isLoading)
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textColorLight),
                    )
                  else 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      onPressed: _handleRegister,
                      child: const Text("Register"),
                    ),
                    const SizedBox(height: 12),

                    if (authProvider.errorMessage != null)
                    Text(
                      authProvider.errorMessage!,
                      style: TextStyle(color: Colors.red[300], fontSize: 16),
                    ),
                ],
              )
            ),
          ),
        )
      ),
    );
  }
}