// CREADO POR: DANIEL INNOVA

import 'package:flutter/material.dart';

class InnovaLoading extends StatelessWidget {
  final String mensaje;

  const InnovaLoading({
    super.key,
    this.mensaje = 'Cargando información...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}