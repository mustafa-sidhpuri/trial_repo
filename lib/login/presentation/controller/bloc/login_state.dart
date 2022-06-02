part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}
class LoginError extends LoginState{
  ErrorParsingModel error;
  LoginError({required this.error});
  @override
  List<Object?> get props => [];

}

class LoginInProcess extends LoginState{
  @override
  List<Object?> get props => [];
}

class LoginSuccess extends LoginState{
  @override
  List<Object?> get props => [];
}