import 'package:bloc_demo_template/features/login/domain/models/login_request_model.dart';
import 'package:bloc_demo_template/features/login/presentation/controller/bloc/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Login Screen"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: "Enter User Name",
              ),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: "Enter Password",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                //
                // "email": "eve.holt@reqres.in",
                // "password": "cityslicka"

                // using Cubit
                // context.read<LoginCubit>().login("eve.holt@reqres.in", "cityslicka");

                // Using Bloc
                context.read<LoginBloc>().add(LoginUser(
                    loginRequest: LoginRequestModel(
                        email: "eve.holt@reqres.in", password: "cityslicka")));
              },
              child: BlocConsumer<LoginBloc, LoginState>(
                  listener: (context, state) {
                if (state is LoginSuccess) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Scaffold(
                                body: Center(
                                  child: Text("Home Screen"),
                                ),
                              )));
                } else if (state is LoginError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(
                      content: Text(state.error.message??"Something went wrong!"),
                      duration: const Duration(milliseconds: 2000),
                    ),
                  );
                }
              }, builder: (context, state) {
                if (state is LoginInProcess) {
                  return const CircularProgressIndicator();
                }
                return const Text("Login");
              }),
            ),
            const Text(
                "Only click above button to login, no need to add credential.")
          ],
        ));
  }
}
