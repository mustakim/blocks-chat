import 'dart:io';

import 'package:dio/dio.dart';
import 'package:l3_flutter_selise_blocksconstruct/core/logger/app_logging.dart';

/// A class that intercepts network requests for logging purposes only. This is
/// the second interceptor in case of both request and response.
///
/// ** This interceptor doesn't modify the request or response in any way. And
/// only works in `debug` mode **
class LoggingInterceptor extends Interceptor {
  /// This method intercepts an out-going request before it reaches the
  /// destination.
  ///
  /// [options] contains http request information and configuration.
  /// [handler] is used to forward, resolve, or reject requests.
  ///
  /// This method is used to log details of all out going requests, then pass
  /// it on after that. It may again be intercepted if there are any
  /// after it. If none, it is passed to [Dio].
  ///
  /// The [RequestInterceptorHandler] in each method controls the what will
  /// happen to the intercepted request. It has 3 possible options:
  ///
  /// - [handler.next]/[super.onRequest], if you want to forward the request.
  /// - [handler.resolve]/[super.onResponse], if you want to resolve the
  /// request with your custom [Response]. All ** request ** interceptors are ignored.
  /// - [handler.reject]/[super.onError], if you want to fail the request
  /// with your custom [DioException].
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final httpMethod = options.method.toUpperCase();
    final url = options.baseUrl + options.path;

    logger
      ..d(message: '--> $httpMethod $url') //GET www.example.com/mock_path/all
      ..d(message: '\tHeaders:');
    options.headers.forEach((k, v) => logger.d(message: '\t\t$k: $v'));

    if (options.queryParameters.isNotEmpty) {
      logger.d(message: '\tqueryParams:');
      options.queryParameters
          .forEach((k, v) => logger.d(message: '\t\t$k: $v'));
    }

    if (options.data != null) {
      logger.d(message: '\tBody: ${options.data}');
    }

    logger.d(message: '--> END $httpMethod');

    return super.onRequest(options, handler);
  }

  /// This method intercepts an incoming response before it reaches Dio.
  ///
  /// [response] contains http [Response] info.
  /// [handler] is used to forward, resolve, or reject responses.
  ///
  /// This method is used to log all details of incoming responses, then pass
  /// it on after that. It may again be intercepted if there are any
  /// after it. If none, it is passed to [Dio].
  ///
  /// The [RequestInterceptorHandler] in each method controls the what will
  /// happen to the intercepted response. It has 3 possible options:
  ///
  /// - [handler.next]/[super.onRequest], if you want to forward the [Response].
  /// - [handler.resolve]/[super.onResponse], if you want to resolve the
  /// [Response] with your custom data. All ** response ** interceptors are ignored.
  /// - [handler.reject]/[super.onError], if you want to fail the response
  /// with your custom [DioException].
  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    logger
      ..d(message: '<-- RESPONSE')
      ..d(message: '\tStatus code: ${response.statusCode}');

    if (response.statusCode == 304) {
      logger.d(message: '\tSource: Cache');
    } else {
      logger.d(message: '\tSource: Network');
    }

    logger
      ..d(message: '\tResponse: ${response.data}')
      ..d(message: '<-- END HTTP');

    return super.onResponse(response, handler);
  }

  /// This method intercepts any exceptions thrown by Dio, or passed from a
  /// previous interceptor.
  ///
  /// [dioError] contains error info when the request failed.
  /// [handler] is used to forward, resolve, or reject errors.
  ///
  /// This method is used to log all details of the error arising due to the
  /// failed request, then pass it on after that. It may again be intercepted
  /// if there are any after it. If none, it is passed to [Dio].
  ///
  /// ** The structure of response in case of errors is dependant on the API and
  /// may not always be the same. It might need changing according to your
  /// own API. **
  ///
  /// The [RequestInterceptorHandler] in each method controls the what will
  /// happen to the intercepted error. It has 3 possible options:
  ///
  /// - [handler.next]/[super.onRequest], if you want to forward the [Response].
  /// - [handler.resolve]/[super.onResponse], if you want to resolve the
  /// [Response] with your custom data. All ** error ** interceptors are ignored.
  /// - [handler.reject]/[super.onError], if you want to fail the response
  /// with your custom [DioException].
  @override
  void onError(
    DioException dioError,
    ErrorInterceptorHandler handler,
  ) {
    logger.d(message: '--> ERROR');
    final httpMethod = dioError.requestOptions.method.toUpperCase();
    final url = dioError.requestOptions.baseUrl + dioError.requestOptions.path;

    logger
      ..d(message: '\tMETHOD: $httpMethod') // GET
      ..d(message: '\tURL: $url'); // URL
    if (dioError.response != null) {
      logger
        ..d(message: '\tStatus code: ${dioError.response!.statusCode}')
        ..d(message: '\tStatus data: ${dioError.response!.data}');
    } else if (dioError.error is SocketException) {
      const message = 'No internet connectivity';
      logger
        ..d(message: '\tException: FetchDataException')
        ..d(message: '\tMessage: $message');
    } else {
      logger.d(message: '\tUnknown Error');
    }

    logger.d(message: '<-- END ERROR');

    return handler.next(dioError);
  }
}
