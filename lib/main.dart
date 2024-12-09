import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prueba_con_python/config/palette.dart';
import 'package:prueba_con_python/screens/all.dart';

const storage = FlutterSecureStorage();
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() {
    return _MyApp();
  }
  // This widget is the root of your application.
}

class _MyApp extends State<MyApp> {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Palette.ktoDark,
        useMaterial3: true,
      ),
      home: FutureBuilder(
          future: jwtOrEmpty,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const CircularProgressIndicator();
            if (snapshot.data != "") {
              var str = snapshot.data;
              var jwt = str?.split(".");

              if (jwt?.length != 3) {
                return const LoginScreen();
              } else {
                var payload = json.decode(
                    ascii.decode(base64.decode(base64.normalize(jwt![1]))));
                if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                    .isAfter(DateTime.now())) {
                  return MessagesPage(str!, payload!);
                  // params to MP str!, payload
                } else {
                  return const LoginScreen();
                }
              }
            } else {
              return const LoginScreen();
            }
          }),
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        MessagesPage.id: (context) => const MessagesPage("", {"null": "null"}),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        DataVisualizationScreen.id: (context) =>
            const DataVisualizationScreen(),
      },
    );
  }
}
