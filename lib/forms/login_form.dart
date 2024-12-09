import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:prueba_con_python/components/rounded_button.dart';
import 'package:prueba_con_python/components/password_textfield.dart';
import 'package:prueba_con_python/screens/messages_screen.dart';

import 'package:prueba_con_python/config/palette.dart';
import 'package:prueba_con_python/screens/all.dart';

const storage = FlutterSecureStorage();

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CustomLoginForm();
  }
}

String email = "";
late String password;

class CustomLoginForm extends State<LoginForm> {
  final myKey = GlobalKey<PasswordFieldState>();
  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _userTextField(),
              PasswordTextField(key: myKey),
              _button(context),
              const Text(
                "O",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _button(context) {
    return RoundedButton(
        title: 'Log In',
        colour: Palette.ktoDark,
        onPressed: () async {
          if (email.isNotEmpty) {
            password = myKey.currentState!.password.text;
            var jwt = await loginUser(context);
            await storage.write(key: "jwt", value: jwt);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MessagesPage.fromBase64(jwt)));
          } else {
            _showError(context);
          }
        });
  }
}

Widget _userTextField() {
  return StreamBuilder(
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextFormField(
          autofocus: false,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            email = value;
          },
          decoration:
              const InputDecoration(hintText: 'Usuario', labelText: "Usuario"),
        ),
      );
    },
    stream: null,
  );
}

Future<String> loginUser(context) async {
  final response = await post(
    Uri.parse('http://10.0.2.2:8080/login'), // http://10.0.2.2:5000/login
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{'username': email, 'password': password}),
  );
  if (response.statusCode == 200) {
    return response.body;
  } else {
    _showError(context);
    throw ("Usuario o contraseña invalidas");
  }
}

void _showError(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ERROR'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text("The username or password is incorrect"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

class User {
  final String username;
  const User({
    required this.username,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['access_token'],
    );
  }
}
