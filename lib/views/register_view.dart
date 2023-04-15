import 'package:bloc_state_management/bloc/app_bloc.dart';
import 'package:bloc_state_management/bloc/app_event.dart';
import 'package:bloc_state_management/extensions/if_dubugging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RegisterView extends HookWidget {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    final emailController =
        useTextEditingController(text: 'osama@gmail.com'.ifDebugging);
    final passwordController =
        useTextEditingController(text: '12345678'.ifDebugging);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              keyboardAppearance: Brightness.dark,
              decoration: const InputDecoration(
                hintText: 'Enter you email here...',
              ),
            ),
            TextField(
              controller: passwordController,
              keyboardAppearance: Brightness.dark,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter you password here...',
              ),
            ),
            TextButton(
              onPressed: () {
                final email = emailController.text;
                final password = passwordController.text;
                context.read<AppBloc>().add(
                      AppEventRegister(
                        email: email,
                        password: password,
                      ),
                    );
              },
              child: const Text('Register'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () {
                context.read<AppBloc>().add(
                      const AppEventGoToLogin(),
                    );
              },
              child: const Text('Already have an account?, Login here!'),
            ),
          ],
        ),
      ),
    );
  }
}
