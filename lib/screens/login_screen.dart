import 'package:flutter/material.dart';
import 'package:prueba_con_python/forms/login_form.dart';
import 'package:prueba_con_python/screens/register_screen.dart';
import '../components/rounded_button.dart';
import '../config/palette.dart';
import 'data_visualisation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/imgs/logo.png',
                height: 200,
              ),
              const LoginForm(),
              buttonRegister(context),
              buttonData(context),
            ],
          ),
        )),
      ),
    );
  }
}

Widget buttonRegister(context) {
  return RoundedButton(
    title: "Registrarse",
    colour: Palette.ktoDark,
    onPressed: () => {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
      )
    },
  );
}

Widget buttonData(context) {
  return RoundedButton(
    title: "Data",
    colour: Palette.ktoDark,
    onPressed: () => {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DataVisualizationScreen(),
        ),
      )
    },
  );
}
