import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_client.dart';
import '../../auth/providers/auth_provider.dart';

final notificacionesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  // Auto-refresh cada 10 segundos
  final timer = Timer(const Duration(seconds: 10), () {
    ref.invalidateSelf();
  });
  ref.onDispose(timer.cancel);

  final user = ref.watch(authProvider).user;
  if (user == null) return [];

  try {
    final response = await apiClient.get('/notificaciones/${user.id}');
    if (response.data is List) {
      return response.data;
    }
    return [];
  } catch (e) {
    debugPrint("Error fetching notifications: $e");
    return [];
  }
});

final marcarNotificacionesLeidasProvider = Provider((ref) {
  return () async {
    final user = ref.read(authProvider).user;
    if (user == null) return;
    try {
      await apiClient.put('/notificaciones/leer/${user.id}');
      ref.invalidate(notificacionesProvider);
    } catch (e) {
      debugPrint("Error marking notifications as read: $e");
    }
  };
});
