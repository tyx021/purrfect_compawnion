import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[50],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Image.asset('assets/Logo.PNG')
            ),
            Expanded(
              flex: 3,
              child: Image.asset('assets/MovingSoccat.GIF'),
            ),
            Expanded(
                flex: 1,
                child: Center(
                  child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink[50],
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          backgroundColor: Colors.pink[50],
                          color: Colors.pink[400],
                          fontSize: 50.0,
                        ),
                      )),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
