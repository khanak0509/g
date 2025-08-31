import 'package:flutter/material.dart';
import 'package:geniebot_app/auth.dart';
import 'package:geniebot_app/chatbot.dart';
import 'package:geniebot_app/login.dart';

class AboutGenieBot extends StatelessWidget {
  const AboutGenieBot({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 13, 33),
      appBar: AppBar(
  title: const Text(
    "About GenieBot",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.deepPurple,
  iconTheme: const IconThemeData(color: Colors.white), 
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
      final user = authService.value.currentUser;

      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(
              username: user.displayName ?? "user",
              email: user.email ?? "no email",
            ),
          ),
        );
      }
    },
  ),
),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "🤖 GenieBot",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, 
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "GenieBot is a multifunctional AI assistant built using "
                "LangChain, LangGraph, and Google Generative AI. It can "
                "interact with GitHub, Google Calendar, Google Forms, SMS "
                "services, and more. It also provides resume parsing, "
                "weather updates, and YouTube/Wikipedia search functionality.",
                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.white),
              ),

              const SizedBox(height: 30),

              const Text(
                "✨ Features",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple, 
                ),
              ),
              const SizedBox(height: 20),

              const FeatureSection(
                title: "1. GitHub Tools",
                features: [
                  "Fetch issues, pull requests, and repository files.",
                  "Create/update/delete files and branches.",
                  "Search issues, PRs, and code.",
                  "Create review requests.",
                ],
              ),
              const SizedBox(height: 20),

              const FeatureSection(
                title: "2. Google Integration",
                features: [
                  "Google Calendar: View and create events.",
                  "Google Forms: Generate forms from a topic using AI.",
                  "Send Google Forms via email.",
                  "Fetch and analyze Google Form responses using Google Sheets.",
                ],
              ),
              const SizedBox(height: 20),

              const FeatureSection(
                title: "3. Communication",
                features: [
                  "Email: Send emails via Gmail SMTP.",
                  "SMS: Send messages using Twilio.",
                ],
              ),
              const SizedBox(height: 20),

              const FeatureSection(
                title: "4. AI & Knowledge",
                features: [
                  "Resume Tool: Generate LinkedIn content from PDF resumes.",
                  "Wikipedia Tool: Query Wikipedia articles.",
                  "YouTube Tool: Search YouTube for relevant content.",
                  "Weather Tool: Fetch current weather (OpenWeatherMap).",
                ],
              ),
              const SizedBox(height: 20),

              const FeatureSection(
                title: "5. Miscellaneous",
                features: [
                  "Current date and time.",
                  "Tavily search integration.",
                ],
              ),

              const SizedBox(height: 40),

              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () {
                    final user = authService.value.currentUser;
                    if (user == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    } 
                    else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp(
                          username: user.displayName ?? "user",
                          email: user.email ?? "no email",
                        )),
                      );
                    }
                  },
                  child: const Text(
                    "🚀 Get Started",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureSection extends StatelessWidget {
  final String title;
  final List<String> features;

  const FeatureSection({
    super.key,
    required this.title,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(height: 8),
        ...features.map(
          (f) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              "• $f",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
