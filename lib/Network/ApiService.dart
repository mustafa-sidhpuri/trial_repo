import 'dart:convert';
import 'dart:io';

import 'package:bloc_demo_template/Constants/LanguageConstants.dart';
import 'package:bloc_demo_template/Constants/PrefKeys.dart';
import 'package:bloc_demo_template/Constants/TimeDurations.dart';
import 'package:bloc_demo_template/DataHandler/Local/SharedPrefs.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/BaseException.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/ErrorCodes.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/ErrorParsingModel.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/utils.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:fimber/fimber.dart';


import 'Utils/NetworkErrorType.dart';

typedef OnError = Function(ErrorParsingModel, bool);
typedef OnSuccess = Function(Map<String,dynamic>);

class ApiService {
  static final ApiService _singleton = ApiService._internal();

  ApiService._internal();

  factory ApiService() {
    return _singleton;
  }

  static Dio dio = Dio();

  int connectionTimeOut = 20000; //5s

  static Future init() async {
    //to by forget secure connection use this piece of code
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    //to avoid redirection to the browser
    dio.options.followRedirects = false;
    //to give support to DIO till response code 500
    dio.options.validateStatus = (status) {
      return status! <= ErrorCodes.serverNotReachable;
    };
    //request should be send between below time
    dio.options.connectTimeout = TimeDurations.connectionTimeOut;
    //response should receive between this time
    dio.options.receiveTimeout = TimeDurations.receiveTimeOut;
    return;
  }

  static getAuthHeaderWithAuthToken() async {
    return {
      dio.options.headers["token"] =
          await UserPreference.getValue(key: PrefKeys.authToken),
      dio.options.headers["Content-Type"] = "application/json"
    };
  }

  static getAuthHeader() async {
    return {dio.options.headers["Content-Type"] = "application/json"};
  }

  static Future<bool> setHeader(bool hasToken) async {
    Fimber.i('Header token required ==> $hasToken');
    if (hasToken) {
      getAuthHeaderWithAuthToken();
    } else {
      getAuthHeader();
    }
    Fimber.i("Header $hasToken Token ===> ${dio.options.headers}");
    return true;
  }

  static Future<void> postRequest({
    required String url,
    Map<String, dynamic>? params,
    bool hasToken = false,
    required OnError onError,
    required OnSuccess onSuccess,
  }) async {
    Fimber.i('Request Type ==> POST');
    if (!await checkInternetConnectionAndShowMessage()) {
      return;
    }
    await setHeader(hasToken);
    try {
      var response = await dio.post(url, data: params);
      logAPIData(response);
      if (isValidResponse(response)) {
        try {
          if(response.data is String){
            onSuccess(json.decode(response.data));
          }else{
            onSuccess(response.data);
          }
        } on BaseException catch (exception) {
          Fimber.i("Exception ${exception.code}");
          Fimber.i("Exception ${exception.message}");
          onSuccess(response.data);
        }
      } else {
        Fimber.i('API Error ==> ${response.statusCode}');
        onError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: response.statusCode,
            action: {},
          ),
          true,
        );
      }
    } on DioError catch (dioError) {
      onError = await getError(dioError: dioError);
    } on SocketException catch (socketException) {
      logException(
        code: socketException.port!,
        message: socketException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.internetNotAvailable,
          code: socketException.port!,
          action: {},
        ),
        true,
      );
      // throw SocketException(socketException.toString());
    } on FormatException catch (formatException) {
      logException(
        code: formatException.offset!,
        message: formatException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: formatException.offset!,
          action: {},
        ),
        true,
      );
      // throw FormatException(formatException.message);
    } on BaseException catch (e) {
      onError(
        ErrorParsingModel(
          message: e.message,
          code: e.code,
          action: {},
        ),
        true,
      );
      // rethrow;
    }
    return;
  }

  static Future<void> deleteRequest({
    required String url,
    Map<String, dynamic>? params,
    bool hasToken = false,
    required OnError onError,
    required OnSuccess onSuccess,
  }) async {
    Fimber.i('Request Type ==> DELETE');
    if (!await checkInternetConnectionAndShowMessage()) {
      return;
    }
    await setHeader(hasToken);
    try {
      var response = await dio.delete(url, data: params);
      logAPIData(response);
      if (isValidResponse(response)) {
        try {
          onSuccess(json.decode(response.data));
        } on BaseException catch (exception) {
          logException(
            code: exception.code!,
            message: exception.message,
          );
          onSuccess(response.data);
        }
      } else {
        onError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: response.statusCode,
            action: {},
          ),
          true,
        );
      }
    } on DioError catch (dioError) {
      onError = await getError(dioError: dioError);
    } on SocketException catch (socketException) {
      logException(
        code: socketException.port!,
        message: socketException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.internetNotAvailable,
          code: socketException.port!,
          action: {},
        ),
        true,
      );
      // throw SocketException(socketException.toString());
    } on FormatException catch (formatException) {
      logException(
        code: formatException.offset!,
        message: formatException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: formatException.offset!,
          action: {},
        ),
        true,
      );
      // throw FormatException(formatException.message);
    } on BaseException catch (e) {
      onError(
        ErrorParsingModel(
          message: e.message,
          code: e.code,
          action: {},
        ),
        true,
      );
      // rethrow;
    }
    return;
  }

  static Future<void> putRequest({
    required String url,
    Map<String, dynamic>? params,
    bool hasToken = false,
    required Function onError,
    required Function onSuccess,
  }) async {
    Fimber.i('Request Type ==> PUT');
    if (!await checkInternetConnectionAndShowMessage()) {
      return;
    }
    await setHeader(hasToken);
    try {
      var response = await dio.put(url, data: params);
      logAPIData(response);
      if (isValidResponse(response)) {
        try {
          if(response.data is String){
            onSuccess(json.decode(response.data));
          } else{
            onSuccess(response.data);
          }
        } on BaseException catch (exception) {
          logException(
            code: exception.code!,
            message: exception.message,
          );
          onSuccess(response.data);
        }
      } else {
        Fimber.i('API Error ==> ${response.statusCode}');
        onError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: response.statusCode,
            action: {},
          ),
          true,
        );
      }
    } on DioError catch (dioError) {
      onError = await getError(dioError: dioError);
    } on SocketException catch (socketException) {
      logException(
        code: socketException.port!,
        message: socketException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.internetNotAvailable,
          code: socketException.port!,
          action: {},
        ),
        true,
      );
      // throw SocketException(socketException.toString());
    } on FormatException catch (formatException) {
      logException(
        code: formatException.offset!,
        message: formatException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: formatException.offset!,
          action: {},
        ),
        true,
      );
      // throw FormatException(formatException.message);
    } on BaseException catch (e) {
      onError(
        ErrorParsingModel(
          message: e.message,
          code: e.code,
          action: {},
        ),
        true,
      );
      // rethrow;
    }
    return;
  }

  static Future<void> getRequest({
    required String url,
    Map<String, dynamic>? params,
    bool hasToken = false,
    required Function onError,
    required Function onSuccess,
  }) async {
    Fimber.i('Request Type ==> GET');
    if (!await checkInternetConnectionAndShowMessage()) {
      return;
    }
    await setHeader(hasToken);
    try {
      var response = await dio.get(
        url,
      );
      logAPIData(response);
      if (isValidResponse(response)) {
        try {
          if(response.data is String){
            onSuccess(json.decode(response.data));
          }else{
            onSuccess(response.data);
          }

        } on BaseException catch (exception) {
          logException(
            code: exception.code!,
            message: exception.message,
          );
          onSuccess(response.data);
        }
      } else {
        Fimber.i('API Error ==> ${response.statusCode}');
        onError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: response.statusCode,
            action: {},
          ),
          true,
        );
      }
    } on DioError catch (dioError) {
      onError = await getError(dioError: dioError);
    } on SocketException catch (socketException) {
      logException(
        code: socketException.port!,
        message: socketException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.internetNotAvailable,
          code: socketException.port!,
          action: {},
        ),
        true,
      );
      // throw SocketException(socketException.toString());
    } on FormatException catch (formatException) {
      logException(
        code: formatException.offset!,
        message: formatException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: formatException.offset!,
          action: {},
        ),
        true,
      );
      // throw FormatException(formatException.message);
    } on BaseException catch (e) {
      onError(
        ErrorParsingModel(
          message: e.message,
          code: e.code,
          action: {},
        ),
        true,
      );
      // rethrow;
    }
    return;
  }

  static bool isValidResponse(Response response) {
    return response.statusCode == ErrorCodes.successStatusCode;
  }

  static Future<void> uploadMediaUser({
    required String mediaType,
    required String image,
    required String url,
    bool hasToken = false,
    required OnError onError,
    required OnSuccess onSuccess,
  }) async {
    // await setHeader(hasToken);
    //
    // try {
    //   FormData formData = await getImageUploadParam(mediaType, image);
    //   var response = await dio.post(url, data: formData);
    //
    //   if (isValidResponse(response)) {
    //     onSuccess(response.data);
    //     Fimber.i("message it's get image");
    //   } else {
    //     Fimber.i('API Error ==> ${response.statusCode}');
    //     onError(response.data['message'], true);
    //   }
    // } catch (e) {
    //   errorHandaling(e, onError);
    // }
    // return;
    Fimber.i('Request Type ==> Multipart');
    if (!await checkInternetConnectionAndShowMessage()) {
      return;
    }
    await setHeader(hasToken);
    try {
      FormData formData = await getImageUploadParam(mediaType, image);
      var response = await dio.post(url, data: formData);
      logAPIData(response);
      if (isValidResponse(response)) {
        try {
          onSuccess(json.decode(response.data));
        } on BaseException catch (exception) {
          logException(
            code: exception.code!,
            message: exception.message,
          );
          onSuccess(response.data);
        }
      } else {
        Fimber.i('API Error ==> ${response.statusCode}');
        onError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: response.statusCode,
            action: {},
          ),
          true,
        );
      }
    } on DioError catch (dioError) {
      onError = await getError(dioError: dioError);
    } on SocketException catch (socketException) {
      logException(
        code: socketException.port!,
        message: socketException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.internetNotAvailable,
          code: socketException.port!,
          action: {},
        ),
        true,
      );
      // throw SocketException(socketException.toString());
    } on FormatException catch (formatException) {
      logException(
        code: formatException.offset!,
        message: formatException.message,
      );
      onError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: formatException.offset!,
          action: {},
        ),
        true,
      );
      // throw FormatException(formatException.message);
    } on BaseException catch (e) {
      onError(
        ErrorParsingModel(
          message: e.message,
          code: e.code,
          action: {},
        ),
        true,
      );
      // rethrow;
    }
    return;
  }

  static Future<FormData> getImageUploadParam(
    String mediaType,
    String imagePath,
  ) async {
    // ttest/re/rwer/w/re/test.png
    List<String> imagePathSlots = imagePath.split("/");
    FormData formData = FormData.fromMap({
      "type": mediaType,
      "file": await MultipartFile.fromFile(imagePath,
          filename: imagePathSlots[imagePathSlots.length - 1]),
    });
    return formData;
  }

  static void logAPIData(Response<dynamic> response) {
    Fimber.i('Request Data ==>  ${response.requestOptions.data}');
    Fimber.i('Requested Endpoint ==>  ${response.requestOptions.path}');
    Fimber.i('Response Data ==>  ${response.data}');
    Fimber.i('Response Status Code ==>  ${response.statusCode}');
    Fimber.i('Response Status Message ==>  ${response.statusMessage}');
  }

  static void logException({required String message, required int code}) {
    Fimber.i('Exception Message ==> $message');
    Fimber.i('Exception Code ==> $code');
  }
}
