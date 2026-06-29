import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:logger/logger.dart';
import 'package:innova_mobile/core/constants/api_constants.dart';

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
}
