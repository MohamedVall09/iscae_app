import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iscae_app/screens/register_screen.dart';
import 'package:iscae_app/screens/home_scren.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("L'email ou le mot de passe ne peut pas être vide")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access'];
        await storeToken(accessToken);

        final userResponse = await http.get(
          Uri.parse('$baseUrl/api/user/'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);
          final annee = userData['annee'];
          final filiere = userData['filiere'];

          if (filiere == null || filiere['id'] == null) {
            throw Exception('Filière manquante pour cet utilisateur');
          }

          final filiereId = filiere['id'];
          final filiereNom = filiere['nom'];

          // Récupérer le premier semestre correspondant
          final semestreResponse = await http.get(
            Uri.parse('$baseUrl/api/semestres/?filiere=$filiereId&annee=$annee'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          );

          if (semestreResponse.statusCode == 200) {
            final semestreData = json.decode(semestreResponse.body);
            final List semestres = semestreData is List
                ? semestreData
                : semestreData['results'] ?? [];

            if (semestres.isEmpty) {
              throw Exception("Aucun semestre trouvé.");
            }

            final semestre = semestres.first;
            final semestreId = semestre['id'];
            final semestreName = semestre['nom'];

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScren(
                  semestreId: semestreId,         // int
                  semestreName: semestreName,     // String
                  filiereId: filiereId,           // int
                  annee: annee,                   // String
                  filiereNom: filiereNom,         // String
                ),
              ),
            );

          } else {
            throw Exception("Erreur de récupération des semestres.");
          }
        } else {
          throw Exception('Erreur de récupération des données utilisateur');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrect')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B7B7B),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/logo-iscae.png'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9B9B),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'CONNEXION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Bon retour ! Ravi de vous revoir :)',
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          labelStyle: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Connexion',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Vous n'avez pas de compte ? Inscrivez-vous ici",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
