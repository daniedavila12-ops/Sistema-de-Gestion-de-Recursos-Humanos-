// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../shared/widgets/innova_text_field.dart';
import '../../../shared/widgets/innova_button.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_center, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'SISTEMA INNOVA',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              if (authState.error != null) ...[
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              InnovaTextField(
                label: 'Correo Electrónico',
                controller: emailController,
              ),
              InnovaTextField(
                label: 'Contraseña',
                controller: passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              InnovaButton(
                text: 'Ingresar',
                isLoading: authState.isLoading,
                onPressed: () async {
                  final success = await ref.read(authProvider.notifier).login(
                        emailController.text,
                        passwordController.text,
                      );
                  if (success && context.mounted) {
                    context.go('/dashboard');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}