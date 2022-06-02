import 'package:bloc_demo_template/DataHandler/Network/ApiService.dart';
import 'package:bloc_demo_template/features/login/domain/models/login_request_model.dart';
import 'package:bloc_demo_template/features/login/domain/repository/LoginRepository.dart';

class Login{
  LoginRepository repository;
  Login({required this.repository});

  Future login(LoginRequestModel loginRequest, OnSuccess onSuccess, Function onError)async{
    await repository.loginUser(loginRequest.transform(), onSuccess, onError);
  }
}