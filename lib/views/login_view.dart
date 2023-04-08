import 'package:bloc_state_management/views/email_text_field.dart';
import 'package:bloc_state_management/views/login_button.dart';
import 'package:bloc_state_management/views/password_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginView extends HookWidget {
  final OnLoginTapped onLoginTapped;

  const LoginView({
    super.key,
    required this.onLoginTapped,
  });

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          EmailTextField(
            emailController: emailController,
          ),
          PasswordTextField(
            passwordController: passwordController,
          ),
          LoginButton(
            emailController: emailController,
            passwordController: passwordController,
            onLoginTapped: onLoginTapped,
          ),
        ],
      ),
    );
  }
}
