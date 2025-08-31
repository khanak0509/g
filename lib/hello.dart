import 'package:flutter/material.dart';
import 'package:geniebot_app/name.dart';

class Hello extends StatefulWidget {
  const Hello({super.key, required this.email});

  final String? email;
  @override
  State<Hello> createState() => _HelloState();
}

class _HelloState extends State<Hello> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 13, 33),
      body: Center(
        child: Container(
          height: 250,
          width: 350,
          decoration: BoxDecoration(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            
              const SizedBox(height: 20),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Name(name: _nameController.text.trim().isEmpty ? '' : _nameController.text.trim(), email: widget.email ?? ''),
                    ),
                  );
                },
                child: const Text("Next"),
              ),
              const SizedBox(height: 20),
             
            ],
          ),
        ),
      ),
    );
  }
}

