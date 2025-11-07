import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        getLogger(
          'AuthWrapper',
        ).fine('ConnectionState = ${snapshot.connectionState}');
        getLogger('AuthWrapper').fine('Has data = ${snapshot.hasData}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          getLogger(
            'AuthWrapper',
          ).info('User authenticated, showing HomeScreen');
          return const HomeScreen();
        } else {
          getLogger(
            'AuthWrapper',
          ).info('User not authenticated, showing LoginScreen');
          return const LoginScreen();
        }
      },
    );
  }
}
