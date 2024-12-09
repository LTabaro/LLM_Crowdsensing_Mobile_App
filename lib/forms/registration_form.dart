import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../components/password_textfield.dart';
import '../components/rounded_button.dart';
import '../config/palette.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return CustomRegisterForm();
  }
}

class CustomRegisterForm extends State<RegisterForm> {
  final passKey1 = GlobalKey<PasswordFieldState>();
  final passKey2 = GlobalKey<PasswordFieldState>();
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _pass1 = "";
  String _pass2 = "";
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _userTextField(),
            const SizedBox(
              height: 8.0,
            ),
            PasswordTextField(key: passKey1),
            PasswordTextField(
              key: passKey2,
              labelText: "Confirm your password",
              hint: "Confirm your password",
            ),
            const SizedBox(
              height: 45.0,
            ),
            RoundedButton(
              title: 'Register',
              colour: Palette.ktoDark,
              onPressed: () async {
                _pass1 = passKey1.currentState!.password.text;
                _pass2 = passKey2.currentState!.password.text;
                if (_email.isNotEmpty &&
                    _pass1.isNotEmpty &&
                    _pass2.isNotEmpty) {
                  if (_pass1 == _pass2) {
                    registerUser(context);
                  } else {
                    _showError(context, message: "Passwords dont match");
                  }
                } else {
                  _showError(context, message: "Rellena todos los campos");
                }
              },
            ),
          ],
        ),
      ),
    );
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
              _email = value;
            },
            decoration: const InputDecoration(
                hintText: 'Usuario', labelText: "Usuario"),
          ),
        );
      },
      stream: null,
    );
  }

  Future<String> registerUser(context) async {
    print('Email: $_email, Password: $_pass1, Confirm Password: $_pass2');

    final response = await post(
      Uri.parse(
          'http://10.0.2.2:8080/register'), // http://10.0.2.2:5000/register
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body:
          jsonEncode(<String, String>{'username': _email, 'password': _pass1}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      _showError(context,
          title: "Bienvenido", message: "Usuario creado satisfactoriamente");
      return response.body;
    } else if (response.statusCode == 409) {
      _showError(context, message: "El usuario ya existe");
      throw ("Usuario o contraseña invalidas");
    } else {
      _showError(context);
      throw ("Usuario o contraseña invalidas");
    }
  }
}

void _showError(context,
    {message = "The username or password is incorrect", title = "'ERROR'"}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
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
