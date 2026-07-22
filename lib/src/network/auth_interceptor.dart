import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:tradeable_flutter_sdk/src/utils/security.dart';
import 'package:tradeable_flutter_sdk/tradeable_flutter_sdk.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final portalToken = TFS().portalToken;
    print(
      'AuthInterceptor: onRequest called with portalToken: $portalToken ${TFS().client}',
    );

    print("${options.method} ${options.baseUrl}${options.path}");

    if (portalToken != null) {
      options.headers['Authorization'] = TFS().authorization ?? '';
      options.headers['x-api-client-id'] = TFS().appId ?? '';
      options.headers['X-SubAccountID'] = TFS().clientId ?? '';
      options.headers['X-AuthToken'] = TFS().portalToken ?? '';
      try {
        options.headers['x-api-encryption-key'] = encryptRsa(
          TFS().secretKey ?? "",
          TFS().publicKey ?? "",
        );
      } catch (e) {
        print('Failed to generate RSA encryption key: $e');
      }
      options.headers['x-axis-token'] = TFS().portalToken ?? '';
      options.headers['x-axis-app-id'] = TFS().appId ?? '';
      options.headers['x-axis-client-id'] = TFS().clientId ?? '';
      options.headers['Content-Type'] = 'application/json';
      options.headers['Accept'] = 'application/json';
    }

    print("${options.headers}");

    if (TFS().publicKey != null &&
        (options.method == 'POST' ||
            options.method == 'PUT' ||
            options.method == 'PATCH')) {
      if (options.data != null) {
        try {
          String encryptedData = await encryptAes(
            TFS().secretKey ?? '',
            jsonEncode(options.data),
          );
          options.data = {'payload': encryptedData};
          print('Encrypted request body: $encryptedData');
        } catch (e) {
          print('Failed to encrypt request body: $e');
        }
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    print(err.response?.toString() ?? "null body");

    if (err.response?.statusCode == 401 ||
        err.response?.statusCode == 403 ||
        err.response?.statusCode == 400) {
      await TFS().onTokenExpired();

      final requestOptions = err.requestOptions;

      _retryWithNewToken(requestOptions, handler);
      return;
    }

    super.onError(err, handler);
  }

  Future<void> _retryWithNewToken(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    if (TFS().portalToken != null) {
      requestOptions.headers['Authorization'] = TFS().authorization ?? '';
      requestOptions.headers['x-api-client-id'] = TFS().appId ?? '';
      requestOptions.headers['X-SubAccountID'] = TFS().clientId ?? '';
      requestOptions.headers['X-AuthToken'] = TFS().portalToken ?? '';
      try {
        requestOptions.headers['x-api-encryption-key'] = encryptRsa(
          TFS().secretKey ?? "",
          TFS().publicKey ?? "",
        );
      } catch (e) {
        print('Failed to generate RSA encryption key on retry: $e');
      }
      requestOptions.headers['x-axis-token'] = TFS().portalToken ?? '';
      requestOptions.headers['x-axis-app-id'] = TFS().appId ?? '';
      requestOptions.headers['x-axis-client-id'] = TFS().clientId ?? '';
      requestOptions.headers['Content-Type'] = 'application/json';
      requestOptions.headers['Accept'] = 'application/json';

      try {
        final dio = Dio();

        final response = await dio.fetch(requestOptions);

        String data = await decryptData(
          TFS().secretKey!,
          response.data['data']['payload'],
        );
        var dataJson = jsonDecode(data);
        response.data = dataJson;

        handler.resolve(response);
      } catch (e) {
        print(e is DioException ? (e.response?.toString() ?? 'null') : '$e');
        handler.next(DioException(requestOptions: requestOptions, error: e));
      }
    } else {
      handler.next(
        DioException(
          requestOptions: requestOptions,
          error: 'Token expired and no new token provided',
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    String data = await decryptData(
      TFS().secretKey!,
      response.data['data']['payload'],
    );
    var dataJson = jsonDecode(data);
    response.data = dataJson;

    super.onResponse(response, handler);
  }
}
