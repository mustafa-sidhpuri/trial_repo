part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginUser extends LoginEvent{
  LoginRequestModel loginRequest;

  LoginUser({required this.loginRequest});

  @override
  List<Object?> get props => [loginRequest];
}
