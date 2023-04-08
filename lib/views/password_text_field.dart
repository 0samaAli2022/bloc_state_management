import 'package:bloc_state_management/strings.dart' show kEnterYourPasswordHere;
import 'package:flutter/material.dart';

class PasswordTextField extends StatelessWidget {
  final TextEditingController passwordController;

  const PasswordTextField({
    super.key,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      obscureText: true,
      obscuringCharacter: '*',
      decoration: const InputDecoration(
        hintText: kEnterYourPasswordHere,
      ),
    );
  }
}
