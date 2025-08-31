import 'package:flutter/material.dart';
import 'package:geniebot_app/deleteaccount.dart';

void main(){
  runApp(Setting());
}

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 5, 13, 33),
        appBar: AppBar(
          leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },

        ),
        backgroundColor: Colors.deepPurple,
          title: Text('Settings',
          style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildSettingsCard(
                context,
                icon: Icons.block,
                title: "Delete Accounts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteAccountScreen(),
                    ),
                  );
                },
              ),
              
              
             
              ],
            )
          ),
        ),
      ),
    );
  }
}
Widget _buildSettingsCard(BuildContext context,
    {required IconData icon,
    required String title,
    required VoidCallback onTap}) {
  return Card(
    color: const Color.fromARGB(255, 58, 2, 169),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.only(bottom: 20),
    child: ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    ),
  );
}
