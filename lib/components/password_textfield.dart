
import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget{
  const PasswordTextField({Key? key, this.labelText="Password", this.hint="Enter your password"}) : super(key: key);
  final String labelText;
  final String hint;
  @override
  State<PasswordTextField> createState() => PasswordFieldState();
}
class PasswordFieldState extends State<PasswordTextField>{
  late bool _obscured;
  late TextEditingController password;

  @override
  void initState(){
    _obscured = false;
    super.initState();
    password = TextEditingController();
  }

  @override
  Widget build(BuildContext context){
    String hintText = widget.hint;
    String labelText = widget.labelText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: password,
        obscureText: !_obscured, //This will obscure text dynamically
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          // Here is key idea
          suffixIcon: IconButton(
            icon: Icon(
              _obscured ? Icons.visibility : Icons.visibility_off,
              color: Theme.of(context).primaryColorDark,
            ),
            onPressed: () {
              setState(() {
                _obscured = !_obscured;
              });
            },
          ),
        ),
      ),
    );
  }
}