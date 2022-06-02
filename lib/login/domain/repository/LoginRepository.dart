import 'package:bloc_demo_template/DataHandler/Network/ApiService.dart';
import 'package:bloc_demo_template/DataHandler/Network/Utils/ErrorParsingModel.dart';
import 'package:bloc_demo_template/features/login/data/entities/login_request_model_entity.dart';
import 'package:bloc_demo_template/features/login/domain/models/login_request_model.dart';

abstract class LoginRepository{

  Future<dynamic> loginUser(LoginRequestEntity loginRequest,OnSuccess onSuccess, Function onError);
}