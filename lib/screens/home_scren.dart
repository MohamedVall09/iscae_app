import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iscae_app/screens/login_screen.dart';
import 'package:iscae_app/screens/section_scren.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScren extends StatefulWidget {
  final int semestreId;
  final String semestreName;
  final int filiereId;
  final String annee;
  final String filiereNom;

  const HomeScren({
    super.key,
    required this.semestreName,
    required this.semestreId,
    required this.filiereId,
    required this.annee,
    required this.filiereNom,
  });

  @override
  State<HomeScren> createState() => _HomeScrenState();
}

class _HomeScrenState extends State<HomeScren> {
  final String baseUrl = dotenv.env['API_BASE_URL']!;
  int _selectedTab = 0;
  String? username;
  String? prenom;
  String? email;
  String? matricule;
  String? filiereNom;
  String? annee;

  bool isLoading = true;

  int? selectedSemestreId;
  List<dynamic> matieres = [];
  List<dynamic> emplois = [];
  List<Map<String, dynamic>> semestresDisponibles = [];

  @override
  void initState() {
    super.initState();
    selectedSemestreId = widget.semestreId;
    fetchUserInfo();
    fetchSemestresDisponibles();
    fetchMatieres();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        username = data['username'];
        prenom = data['prenom'];
        email = data['email'];
        matricule = data['matricule'];
        filiereNom = data['filiere']['nom']; 
        annee = data['annee'];
      });
    }
  }

  Future<void> fetchSemestresDisponibles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final anneeUpper = widget.annee.toUpperCase();
    

    final response = await http.get(
      Uri.parse('$baseUrl/api/semestres/?filiere=${widget.filiereId}&annee=$anneeUpper'),
      headers: {'Authorization': 'Bearer $token'},
    );



    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        semestresDisponibles = decoded is List
            ? List<Map<String, dynamic>>.from(decoded)
            : [];
      });
    } else {
      print('Erreur lors du chargement des semestres: ${response.statusCode}');
    }
  }

  Future<void> fetchMatieres() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/matieres/?semestre=$selectedSemestreId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        matieres = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  Future<void> fetchEmplois() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/emplois_du_temps/?semestre=$selectedSemestreId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        emplois = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B7B7B),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); 
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.black),
                  onPressed: () => _showProfileDialog(),
                ),
              ],
            ),
            const CircleAvatar(
              radius: 50.0,
              backgroundImage: AssetImage('images/logo-iscae.png'),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9B9B),
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${filiereNom ?? ''} (${annee ?? ''})',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B9B9B),
                    border: Border.all(width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    value: selectedSemestreId,
                    dropdownColor: const Color(0xFF6B9B9B),
                    iconEnabledColor: Colors.black,
                    underline: Container(),
                    onChanged: (value) {
                      final selected = semestresDisponibles.firstWhere((s) => s['id'] == value);
                      setState(() {
                        selectedSemestreId = value!;
                        isLoading = true;
                      });
                      fetchMatieres();
                      fetchEmplois();
                    },
                    items: semestresDisponibles.map((sem) {
                      return DropdownMenuItem<int>(
                        value: sem['id'],
                        child: Text(
                          sem['nom'],
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab(0, Icons.subject, 'Matériaux'),
                _buildTab(1, Icons.access_time, 'Emplois du temps'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9B9B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _selectedTab == 0
                        ? GridView.count(
                            crossAxisCount: 3,
                            padding: const EdgeInsets.all(16),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            children: matieres.map((matiere) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4B7B7B),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => SectionScren(
                                        matiereId: matiere['id'],
                                        matiereNom: matiere['nom'],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(matiere['nom'], textAlign: TextAlign.center),
                              );
                            }).toList(),
                          )
                        : ListView.builder(
                            itemCount: emplois.length,
                            itemBuilder: (context, index) {
                              final e = emplois[index];
                              return Card(
                                color: const Color(0xFF4B7B7B),
                                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                child: ListTile(
                                  title: Text(
                                    '${e['jour']} — ${e['heure_debut']} à ${e['heure_fin']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    e['matiere'],
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          isLoading = true;
          index == 0 ? fetchMatieres() : fetchEmplois();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF4B7B7B),
        title: const Center(
          child: Text(
            'Profil',
            style: TextStyle(color: Colors.black),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Matricule: I${matricule ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Nom: ${username ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Prénom: ${prenom ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Email: ${email ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Filière: ${filiereNom ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text('Année: ${annee ?? ''}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await logout();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
