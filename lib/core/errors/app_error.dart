import 'package:dio/dio.dart';

class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

String humanizeError(Object error) {
  if (error is AppException) return error.message;
  if (error is DioException) return ApiErrorMapper.messageFromDio(error);
  final text = error.toString().replaceFirst('Exception: ', '').trim();
  if (text.isEmpty) return 'Terjadi kesalahan. Silakan coba lagi.';
  return text;
}

abstract final class ApiErrorMapper {
  static AppException fromDio(DioException error) {
    final response = error.response;
    final status = response?.statusCode;
    final data = response?.data;

    String? code;
    String? message;

    if (data is Map<String, dynamic>) {
      code = data['code']?.toString();
      message = data['message']?.toString();
    }

    message ??= _messageFromStatus(status, error.type);
    return AppException(message, code: code, statusCode: status);
  }

  static String messageFromDio(DioException error) => fromDio(error).message;

  static String _messageFromStatus(int? status, DioExceptionType type) {
    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout) {
      return 'Koneksi ke server terlalu lama. Periksa jaringan lalu coba lagi.';
    }
    if (type == DioExceptionType.connectionError ||
        type == DioExceptionType.unknown) {
      return 'Belum bisa tersambung. Coba cek koneksi atau nyalakan layanan aplikasinya.';
    }

    switch (status) {
      case 400:
        return 'Permintaan tidak valid.';
      case 401:
        return 'Sesi berakhir. Silakan masuk kembali.';
      case 403:
        return 'Kamu tidak memiliki akses untuk tindakan ini.';
      case 404:
        return 'Data tidak ditemukan.';
      case 409:
        return 'Data sudah ada atau terjadi konflik.';
      case 422:
        return 'Data yang dikirim belum sesuai. Periksa kembali isianmu.';
      case 429:
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
      case 500:
      case 502:
      case 503:
      case 504:
        return 'Server sedang bermasalah. Silakan coba lagi nanti.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
