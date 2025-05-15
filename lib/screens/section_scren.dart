import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:iscae_app/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

class SectionScren extends StatefulWidget {
  final int matiereId;
  final String matiereNom;

  const SectionScren({super.key, required this.matiereId, required this.matiereNom});

  @override
  State<SectionScren> createState() => _SectionScrenState();
}

class _SectionScrenState extends State<SectionScren> {
  String baseUrl = dotenv.env['API_BASE_URL']!;
  int _selectedTab = 0;

  String? username;
  String? email;
  List<dynamic> coursList = [];
  List<dynamic> archiveList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchCours();
  }

  Future<void> fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        username = data['username'];
        email = data['email'];
      });
    }
  }

  Future<void> fetchCours() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/cours/?matiere=${widget.matiereId}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        coursList = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  Future<void> fetchArchives() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/api/archives/?matiere=${widget.matiereId}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      setState(() {
        archiveList = jsonDecode(response.body);
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> openPdf(String url, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');

    if (!await file.exists()) {
      await Dio().download(url, file.path);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('PDF Viewer'),
            backgroundColor: const Color(0xFF4B7B7B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  final externalDir = await getExternalStorageDirectory();
                  final targetPath = '${externalDir!.path}/$fileName';
                  await file.copy(targetPath);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF téléchargé dans : $targetPath')),
                  );
                },
              ),
            ],
          ),
          body: PDFView(filePath: file.path),
        ),
      ),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                IconButton(
                  icon: const Icon(Icons.account_circle, color: Colors.black),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: const Color(0xFF4B7B7B),
                        title: const Center(child: Text('Profil')),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('titre: ${username ?? ''}', style: const TextStyle(fontSize: 18, color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('Email: ${email ?? ''}', style: const TextStyle(fontSize: 16, color: Colors.white70)),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await logout();
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Déconnexion'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const CircleAvatar(radius: 50.0, backgroundImage: AssetImage('images/logo-iscae.png')),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B9B9B),
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(widget.matiereNom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            const SizedBox(height: 25),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(0, Icons.menu_book, 'Cours'),
                  _buildTab(1, Icons.archive, 'Archive'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B9B9B),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _selectedTab == 0
                    ? isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : coursList.isEmpty
                            ? const Center(child: Text('Aucun cours trouvé', style: TextStyle(color: Colors.black54)))
                            : _buildPdfGrid(coursList)
                    : archiveList.isEmpty
                        ? const Center(child: Text('Aucune archive trouvée', style: TextStyle(color: Colors.black54)))
                        : _buildPdfGrid(archiveList),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF6B9B9B),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/location');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Localisation'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        if (index == 1) fetchArchives();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfGrid(List<dynamic> list) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 24),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: list.map((item) {
        final fichier = item['fichier'];
        final fileUrl = fichier.startsWith('http') ? fichier : '$baseUrl$fichier';
        final titre = item['titre'] ?? 'Document';

        return ElevatedButton(
          onPressed: () => openPdf(fileUrl, '$titre.pdf'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B7B7B),
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf, color: Colors.black, size: 25),
              const SizedBox(height: 8),
              Text(titre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
