import '../../../core/api/api_client.dart';
import '../models/log_model.dart';

class LogRepository {
  Future<List<LogSistema>> getLogs() async {
    final response = await apiClient.get('/logs');
    final List data = response.data is List ? response.data : (response.data['data'] ?? []);
    return data.map((json) => LogSistema.fromJson(json)).toList();
  }
}
