import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geniebot_app/username.dart';


class Name extends StatefulWidget {
  final String name;
  final String email;
  const Name({super.key, required this.name, required this.email});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Username(name: widget.name, email: widget.email)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 13, 33),
      body: Center(
        child: Text(
          'Hello ${widget.name}',
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
