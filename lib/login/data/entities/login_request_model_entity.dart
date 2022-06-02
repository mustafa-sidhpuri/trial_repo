class LoginRequestEntity{
  final String email;
  final String password;

  LoginRequestEntity({required this.email, required this.password});

  factory LoginRequestEntity.fromJson(Map<String,dynamic> json){
    return LoginRequestEntity(email: json["email"], password: json["password"]);
  }

  Map<String,dynamic> toJson(){
    return {
      "email":email,
      "password": password
    };
  }

}