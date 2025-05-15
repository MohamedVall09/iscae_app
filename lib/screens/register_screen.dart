import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:iscae_app/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final matriculeController = TextEditingController();
  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedFiliere;
  String? selectedAnnee;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    matriculeController.addListener(_onMatriculeChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    matriculeController.removeListener(_onMatriculeChanged);
    super.dispose();
  }

  void _onMatriculeChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      fetchUserByMatricule();
    });
  }

  Future<void> fetchUserByMatricule() async {
    final matricule = matriculeController.text.trim();
    final baseUrl = dotenv.env['API_BASE_URL']!;

    if (matricule.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/get_user_by_matricule/?matricule=$matricule'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nameController.text = data['username'] ?? '';
          prenomController.text = data['prenom'] ?? '';
          emailController.text = data['email'] ?? '';
          selectedFiliere = data['filiere']?['nom'];
          selectedAnnee = data['annee'];
        });
      } else {
        setState(() {
          nameController.clear();
          prenomController.clear();
          emailController.clear();
          selectedFiliere = null;
          selectedAnnee = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matricule non trouvé')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  Future<void> register() async {
    final matricule = matriculeController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final baseUrl = dotenv.env['API_BASE_URL']!;
    final email = emailController.text.trim();

    if (matricule.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'matricule': matricule,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie')),
        );
        Navigator.pop(context);
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['message'] ?? 'Erreur lors de l\'inscription')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B7B7B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B7B7B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('images/logo-iscae.png'),
                ),
                const SizedBox(height: 16),
                const Text(
                  "INSCRIPTION",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const Text("Créer un nouveau compte", style: TextStyle(color: Colors.black)),
                const SizedBox(height: 24),

                TextField(
                  controller: matriculeController,
                  decoration: const InputDecoration(
                    labelText: 'Matricule :',
                    prefixText: 'I',
                    prefixStyle: TextStyle(color: Colors.black, fontSize: 16),
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Nom  :',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: prenomController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Prénom :',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email :',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Filière :',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                  controller: TextEditingController(text: selectedFiliere ?? ''),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Année :',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  ),
                  controller: TextEditingController(text: selectedAnnee ?? ''),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer mot de passe',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: register,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text(
                        "S'inscrire",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
