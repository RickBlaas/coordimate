import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final storage = const FlutterSecureStorage();
  final logger = Logger();

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    final response = await http.post(
      Uri.parse('https://team-management-api.dops.tech/api/v2/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': data.name,
        'password': data.password,
      }),
    );

    logger.d('Response status: ${response.statusCode}');
    logger.d('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      final jwt = responseJson['data']['token'];
      final userId = responseJson['data']['id'];
      logger.d('token test login: $jwt');

      // Store the JWT securely
      await storage.write(key: 'jwt', value: jwt);

      // Store the user ID securely
      await storage.write(key: 'user_id', value: userId.toString());

      // Use a mounted check before navigating
      if (mounted) {
        context.go('/home');
      }
      return null; // Login successful
    } else {
      final responseJson = jsonDecode(response.body);
      final errors = responseJson['error'] as List;
      return errors.first as String; 
    }
  }

  Future<String?> _registerUser(SignupData data) async {
    final response = await http.post(
      Uri.parse('https://team-management-api.dops.tech/api/v2/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': data.name!,
        'password': data.password!,
      }),
    );

    // Log the response for debugging
    logger.d('Response status: ${response.statusCode}');
    logger.d('Response body: ${response.body}');
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return null; // Registration successful
    } else {
      final errorMessage = responseJson['message'] ?? 'Registration failed';
      logger.e('Registration failed: $errorMessage');
      return errorMessage;
    }
  }

  Future<String?> _recoverPassword(String name) async {
    // Dummy implementation
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Coordimate',
      onLogin: (loginData) => _authUser(loginData),
      onSignup: _registerUser,
      onRecoverPassword: _recoverPassword,
      onSubmitAnimationCompleted: () {
        // Navigate only if the widget is still mounted
        if (mounted) {
          context.go('/home');
        }
      },
      hideForgotPasswordButton: true,
      messages: LoginMessages(
        userHint: 'Username',
        passwordHint: 'Password',
        confirmPasswordHint: 'Confirm Password',
        loginButton: 'LOGIN',
        signupButton: 'REGISTER',
        goBackButton: 'BACK',
        confirmPasswordError: 'Passwords do not match!',
        flushbarTitleError: 'Error', // Add this
        flushbarTitleSuccess: 'Success', // Add this
      ),
      userValidator: (value) {
        if (value == null || value.isEmpty) {
          return 'Username is required';
        }
        return null;
      },
    );
  }
}
