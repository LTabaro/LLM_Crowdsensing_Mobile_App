import 'package:flutter/material.dart';
import '../config/palette.dart';
import '../screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
const storage = FlutterSecureStorage();
class NavigationDrawerMenu extends StatelessWidget {
  const NavigationDrawerMenu({Key? key}) : super(key: key);
  static const padding = EdgeInsets.symmetric(horizontal: 20);
  // void _closeDrawer() {
  //   Navigator.of(context).pop();
  // }
  @override
  Widget build(BuildContext context) {
    const name = "Andrew Oxford";
    const email = "jj@ipn.mx";
    const urlImage =
        "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80";

    return Drawer(
      child: Material(
        color: Palette.ktoDark[10],
        child: ListView(
          //padding: padding,
          children: <Widget>[
            buildHeader(
              urlImage: urlImage,
              name: name,
              email: email,
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  buildMenuItem(
                    text: 'Home',
                    icon: Icons.home,
                    onClicked: () => selectedItem(context, 0),
                  ),
                  buildMenuItem(
                    text: 'Messages',
                    icon: Icons.message,
                    onClicked: () => selectedItem(context, 1),
                  ),
                  buildMenuItem(
                    text: 'Groups',
                    icon: Icons.people,
                  ),
                  buildMenuItem(
                    text: 'Updates',
                    icon: Icons.update,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Divider(color: Colors.white70,),
                  const SizedBox( height: 20, ),
                  buildMenuItem(
                      text: 'Notifications', icon: Icons.notifications),
                  buildMenuItem(
                    text: 'Saved items',
                    icon: Icons.bookmark,
                  ),
                  const Divider(color: Colors.white70,),
                  const SizedBox( height: 20, ),
                  buildMenuItem(
                    text: "Log out",
                    icon: Icons.logout,
                    onClicked: () async{
                      await storage.deleteAll();
                      if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginScreen()));

                    },),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white30;
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: const TextStyle(color: color),
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  Widget buildHeader(
      {required String urlImage,
        required String name,
        required String email}) =>
      InkWell(
        child: Container(
          padding: padding.add(const EdgeInsets.symmetric(vertical: 40)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(urlImage),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  )
                ],
              ),
              // const Spacer(),
              // const CircleAvatar(
              //   radius: 24,
              //   backgroundColor: Color.fromRGBO(30, 60, 168, 1),
              //   child: Icon(Icons.add_comment_outlined, color: Colors.white),
              // ),
            ],
          ),
        ),
      );

  void selectedItem(BuildContext context, int i) {
    Navigator.of(context).pop();
    switch (i) {
      case 0:
        Navigator.popUntil(context, ModalRoute.withName('/'));
        break;
      case 1:
        // Navigator.of(context).push(
        //     MaterialPageRoute(builder: (context) => const MessagesPage()));
        // break;
      default:
    }
  }
}
