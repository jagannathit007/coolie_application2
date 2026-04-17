import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/response_model.dart';
import '../services/app_storage.dart';
import '../services/app_toasting.dart';
import 'network_constants.dart';

class ApiManager {
  final Dio _dio = Dio();
  static const int _timeout = NetworkConstants.sendTimeout;

  ApiManager(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: _timeout);
    _dio.options.receiveTimeout = const Duration(milliseconds: _timeout);
    _dio.options.sendTimeout = const Duration(milliseconds: _timeout);
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_AuthInterceptor());
  }

  Future<ResponseModel> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      return _parseDioError(e);
    }
  }

  ResponseModel _parseDioError(DioException error) {
    if (error.response != null && error.response!.data != null) {
      var responseModel = ResponseModel.fromJson(error.response!.data);
      errorToast(responseModel.message);
      return responseModel;
    } else {
      String message = _getErrorMessage(error);
      errorToast(message);
      return ResponseModel(message: message, data: null, status: error.response?.statusCode ?? 500);
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out';
      case DioExceptionType.connectionError:
        return 'Connection error';
      case DioExceptionType.badCertificate:
        return 'Bad certificate';
      case DioExceptionType.badResponse:
        return 'Server error occurred';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.unknown:
        return 'Unknown error occurred';
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print("URI: ${options.uri}");
      print('REQUEST[${options.method}] => PATH: ${options.path}');
      print('HEADERS: ${options.headers}');
      print('Authorization: ${options.headers['Authorization']}');
      if (options.data != null) print('BODY: ${options.data}');
      if (options.queryParameters.isNotEmpty) {
        print('QUERY PARAMS: ${options.queryParameters}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('DATA: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('ERROR DATA: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = AppStorage.read<String?>('token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint("AuthorizationToken : $token");
    }
    super.onRequest(options, handler);
  }
}

final apiManager = ApiManager(NetworkConstants.baseUrl);
