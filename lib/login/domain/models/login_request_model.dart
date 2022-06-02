import 'package:bloc_demo_template/features/login/data/entities/login_request_model_entity.dart';

class LoginRequestModel{
  final String email;
  final String password;

  LoginRequestModel({required this.email, required this.password});

  LoginRequestEntity transform(){
    return LoginRequestEntity(email: email, password: password);
  }
}