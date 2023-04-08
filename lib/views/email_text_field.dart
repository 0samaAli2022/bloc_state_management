import 'package:bloc_state_management/strings.dart' show kEnterYourEmailHere;
import 'package:flutter/material.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController emailController;

  const EmailTextField({
    super.key,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      decoration: const InputDecoration(
        hintText: kEnterYourEmailHere,
      ),
    );
  }
}
