import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_demo_template/DataHandler/Local/SharedPrefs.dart';
import 'package:bloc_demo_template/DataHandler/Local/keys.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/ErrorParsingModel.dart';
import 'package:bloc_demo_template/features/login/domain/models/login_request_model.dart';
import 'package:bloc_demo_template/features/login/domain/usecases/login_user.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  Login login;
  LoginBloc({required this.login}) : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      if (event is LoginUser) {
        emit(LoginInProcess());
        await login.login(event.loginRequest,
                (Map<String, dynamic> json) {
                    UserPreference.setValue(key: Keys.tokenKey,value:json["token"]);
                    emit(LoginSuccess());
                },
            (ErrorParsingModel error) {
                emit(LoginError(error: error));
            });
      }
    });
  }
}
