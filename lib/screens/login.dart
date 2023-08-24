// ignore_for_file: avoid_print

import 'package:encuentas/screens/encuesta/lista.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool obscureText = true;
  TextEditingController ctrlUserName = TextEditingController();
  TextEditingController ctrlPass = TextEditingController();
  TextEditingController ctrlCodeTest = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double withPage = 0.8;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Login'),
      ),
      body: Center(
        child: FractionallySizedBox(widthFactor: withPage, child: buildBody()),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Chamitos app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: ctrlUserName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "User name",
                    fillColor: Colors.transparent,
                    filled: true,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  obscureText: obscureText,
                  keyboardType: TextInputType.text,
                  controller: ctrlPass,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: fntObscureText,
                      icon: Icon(obscureText
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    labelText: "Password",
                    fillColor: Colors.transparent,
                    filled: true,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fntLogin,
                  child: const Text('Log In'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: ctrlCodeTest,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Code",
                  fillColor: Colors.transparent,
                  filled: true,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: fntGoEncuesta,
              child: const Text('Ir a encuesta'),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  fntObscureText() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  fntLogin() {
    print('press btn');
    print(ctrlUserName.text);
    print(ctrlPass.text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MostrarEncuestas()),
    );
  }

  fntGoEncuesta() {
    print('press btn ir a encuesta');
  }
}
