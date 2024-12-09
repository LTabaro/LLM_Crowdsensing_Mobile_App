import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:prueba_con_python/config/palette.dart';
import 'package:prueba_con_python/components/navigation_drawer_menu.dart';

const storage = FlutterSecureStorage();

class MessagesPage extends StatefulWidget {
  const MessagesPage(this.jwt, this.payload, {super.key});
  static const String id = 'message_screen';

  factory MessagesPage.fromBase64(String jwt) => MessagesPage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));
  final String jwt;
  final Map<String, dynamic> payload;
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  Future<Data>? futureData;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String username = widget.payload["sub"];
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Mensajes',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Palette.ktoDark,
      ),
      drawer: const NavigationDrawerMenu(),
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
        //MessagesStream(),
        Row(children: <Widget>[
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Palette.ktoDark, width: 3)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Palette.ktoDark[10]!, width: 3.0),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Palette.ktoDark, width: 2.0)),
                  hintText: 'Escribe aqui tu mensaje',
                ),
              ),
            ),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                backgroundColor: Palette.ktoDark,
                foregroundColor: Colors.white),
            child: const Text("Enviar"),
            onPressed: () => {
              //log(widget.payload["sub"].runtimeType as String)
              setState(
                () {
                  futureData = sendMessage(_controller.text, username);
                },
              ),
            },
          ),
        ]),
      ]),
    ));
  }

  FutureBuilder<Data> buildFutureBuilder() {
    return FutureBuilder<Data>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(
            snapshot.data!.information.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          );
        } else if (snapshot.hasError) {
          return Text(
            '${snapshot.error}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

Future<Data> sendMessage(String message, String username) async {
  final response = await post(
    Uri.parse('http://10.0.2.2:8080/send'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'user': username,
      'message': message,
    }),
  );
  if (response.statusCode == 200) {
    //print(Data.fromJson(jsonDecode(response.body)).information);
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Data.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 EATED response,
    // then throw an exception.
    throw Exception('Failed to send the message.');
  }
}

class Data {
  final String information;
  const Data({
    required this.information,
  });
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      information: json['class'],
    );
  }
}
