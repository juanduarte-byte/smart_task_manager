
// ignore_for_file: eol_at_end_of_file

import 'package:dio/dio.dart';

class NetworkException implements Exception {
  NetworkException(this.message);

  factory NetworkException.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Tiempo de conexión agotado. Revisa tu conexión.',
        );
      case DioExceptionType.badResponse:
        return NetworkException._handleStatusCode(
          dioError.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return NetworkException('Solicitud cancelada.');
      case DioExceptionType.connectionError:
        return NetworkException(
          'Sin conexión a internet. Intenta nuevamente.',
        );
      case DioExceptionType.unknown:
        return NetworkException(
          'Error desconocido: ${dioError.message}',
        );
      case DioExceptionType.badCertificate:
        return NetworkException('Error de certificado.');
    }
  }

  factory NetworkException._handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return NetworkException('Solicitud inválida.');
      case 401:
        return NetworkException('No autorizado. Reingresa.');
      case 403:
        return NetworkException('Acceso prohibido.');
      case 404:
        return NetworkException('Recurso no encontrado.');
      case 500:
        return NetworkException('Error interno del servidor.');
      case 502:
        return NetworkException('Bad Gateway.');
      case 503:
        return NetworkException('Servicio no disponible.');
      default:
        return NetworkException('Error HTTP: $statusCode');
    }
  }

  final String message;

  @override
  String toString() => message;
}

// EOF



