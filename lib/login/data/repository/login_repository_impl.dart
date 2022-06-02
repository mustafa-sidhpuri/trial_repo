import 'package:bloc_demo_template/DataHandler/Network/ApiService.dart';
import 'package:bloc_demo_template/features/login/data/entities/login_request_model_entity.dart';
import 'package:bloc_demo_template/features/login/domain/repository/LoginRepository.dart';

class LoginRepositoryImpl implements LoginRepository{
  @override
  Future loginUser(LoginRequestEntity loginRequest, OnSuccess onSuccess, Function onError) {
    // TODO: implement loginUser
    throw UnimplementedError();
  }

}