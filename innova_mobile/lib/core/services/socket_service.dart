import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers to invalidate
import 'package:innova_mobile/features/empleados/providers/empleado_provider.dart';
import 'package:innova_mobile/features/empleados/screens/contrato_provider.dart';
import 'package:innova_mobile/features/empleados/screens/vacaciones_empleado_provider.dart';
import 'package:innova_mobile/features/empleados/screens/faltas_empleado_provider.dart';
import 'package:innova_mobile/features/empleados/screens/notas_empleado_provider.dart';
import 'package:innova_mobile/features/empleados/screens/documentos_empleado_provider.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  SocketService._internal() {
    // NOTA: La IP debe ser la de tu servidor backend.
    // Si usas un emulador de Android, usa 10.0.2.2 para referirte al localhost de tu máquina.
    // Si usas un dispositivo físico, asegúrate de que esté en la misma red y usa la IP de tu máquina.
    _socket = io.io(ApiConstants.baseUrl, <String, dynamic>{ 
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();

    final logger = Logger();

    _socket.onConnect((_) {
      logger.i('✅ Socket.IO: Conectado al servidor');
    });

    _socket.onDisconnect((_) {
      logger.w('❌ Socket.IO: Desconectado del servidor');
    });

    _socket.onConnectError((data) {
      logger.e('❌ Socket.IO: Error de conexión: $data');
    });

    _socket.onError((data) {
      logger.e('❌ Socket.IO: Error general: $data');
    });
  }

  late io.Socket _socket;

  io.Socket get socket => _socket;

  bool _listenersInitialized = false;

  void initListeners(WidgetRef ref) {
    if (_listenersInitialized) return;
    _listenersInitialized = true;

    _socket.on('refresh_empleados', (_) {
      ref.invalidate(empleadosProvider);
    });

    _socket.on('refresh_empleado_detalle', (data) {
      if (data != null) {
        final id = data is int ? data : int.tryParse(data.toString());
        if (id != null) {
          ref.invalidate(empleadosProvider);
          ref.invalidate(contratosProvider(id));
          ref.invalidate(vacacionesEmpleadoProvider(id));
          ref.invalidate(faltasEmpleadoProvider(id));
          ref.invalidate(notasEmpleadoProvider(id));
          ref.invalidate(documentosEmpleadoProvider(id));
        }
      }
    });
  }
}
