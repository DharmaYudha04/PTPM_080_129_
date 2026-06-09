import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';

class AiRemoteDataSource {
  AiRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;
  String? _conversationId;

  Stream<String> streamReply({
    required String prompt,
    List<Map<String, String>> history = const [],
  }) async* {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/ai/guide/chat',
        data: {
          'message': prompt,
          if (_conversationId != null) 'conversationId': _conversationId,
        },
        options: Options(responseType: ResponseType.json),
      );

      final data = response.data ?? const <String, dynamic>{};
      _conversationId = data['conversationId'] as String? ?? _conversationId;

      final answer = data['answer'] as String?;
      if (answer == null || answer.trim().isEmpty) {
        yield 'Kanca Jogja belum sempat menjawab. Coba tanyakan lagi, nggih.';
        return;
      }

      yield* _typewriter(answer.trim());
    } catch (error) {
      yield _friendlyBackendError(error);
    }
  }

  void resetConversation() {
    _conversationId = null;
  }

  Stream<String> _typewriter(String text) async* {
    final tokens = text.split(' ');
    var buffer = '';

    for (final token in tokens) {
      await Future<void>.delayed(const Duration(milliseconds: 22));
      buffer = '$buffer $token'.trim();
      yield buffer;
    }
  }

  String _friendlyBackendError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        return 'Silakan login ulang agar Kanca Jogja bisa membaca preferensi akun Anda.';
      }
      if (statusCode == 404) {
        return 'Kanca Jogja belum siap menjawab. Coba nyalakan layanan aplikasi dulu.';
      }
      if (statusCode != null) {
        return 'Kanca Jogja belum bisa dihubungi. Backend merespons HTTP $statusCode.';
      }
      return 'Kanca Jogja belum bisa tersambung. Coba cek koneksi dan layanan aplikasi.';
    }

    return 'Kanca Jogja sedang belum siap. Coba lagi sebentar, nggih.';
  }
}
