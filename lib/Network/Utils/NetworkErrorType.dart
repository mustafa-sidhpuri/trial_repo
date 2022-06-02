import 'package:bloc_demo_template/Constants/LanguageConstants.dart';
import 'package:bloc_demo_template/DataHandler/Network/ApiService.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/ErrorParsingModel.dart';
import 'package:dio/dio.dart';


late OnError networkError ;

Future<OnError> getError({
  required DioError dioError,
}) {

  switch (dioError.type) {
    case DioErrorType.connectTimeout:
      return networkError(
        ErrorParsingModel(
          message: LanguageConst.networkConnectionTimeout,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );
    case DioErrorType.sendTimeout:
      return networkError(
        ErrorParsingModel(
          message: LanguageConst.networkSendTimeout,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );

    case DioErrorType.receiveTimeout:
      return networkError(
        ErrorParsingModel(
          message: LanguageConst.networkReceiveTimeout,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );

    case DioErrorType.response:
      final response = dioError.response;
      if (response == null) {
        // This should never happen, judging by the current source code
        // for Dio.
        return networkError(
          ErrorParsingModel(
            message: LanguageConst.somethingWentWrong,
            code: dioError.response?.statusCode,
            action: {},
          ),
          true,
        );
      }

      return networkError(
        ErrorParsingModel(
          message: response.data.toString(),
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );

    case DioErrorType.cancel:
      return networkError(
        ErrorParsingModel(
          message: dioError.message,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );

    case DioErrorType.other:
      return networkError(
        ErrorParsingModel(
          message: dioError.message,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );
    default:
      return networkError(
        ErrorParsingModel(
          message: LanguageConst.somethingWentWrong,
          code: dioError.response?.statusCode,
          action: {},
        ),
        true,
      );
  }
}
