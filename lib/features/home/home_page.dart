import 'package:flutter/material.dart';
import '../../services/shared_preferences_services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/shared_preferences_services.dart';
import '../sprints/sprint.dart';
import '../sprints/sprint_card.dart';
import '../sprints/sprint_details_page.dart';
import '../onboarding/onboarding_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Sprint> _sprints = [];
  String? _userName;
  String? _userEmail;
  String? _profileImagePath;
  Uint8List? _profileImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    if (kIsWeb) {
      final base64 = await SharedPreferencesService.getProfileImageBase64();
      setState(() {
        _profileImageBytes = base64 != null ? base64Decode(base64) : null;
      });
    } else {
      final imagePath = await SharedPreferencesService.getProfileImagePath();
      setState(() {
        _profileImagePath = imagePath;
      });
    }
    setState(() {
      _userName = name;
      _userEmail = email;
    });
  }

  void _showCreateSprintDialog() {
    final titleController = TextEditingController();
    final pagesController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Sprint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título do material'),
              ),
              TextField(
                controller: pagesController,
                decoration: const InputDecoration(labelText: 'Total de páginas'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duração (dias)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final totalPages = int.tryParse(pagesController.text) ?? 0;
                final durationInDays = int.tryParse(durationController.text) ?? 0;

                if (title.isNotEmpty && totalPages > 0 && durationInDays > 0) {
                  setState(() {
                    _sprints.add(
                      Sprint(
                        title: title,
                        totalPages: totalPages,
                        durationInDays: durationInDays,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Criar Sprint'),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog() {
    bool deletePersonalData = false;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Privacidade & Consentimentos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Revogar consentimento para marketing (sempre revogado).',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Apagar dados pessoais (nome e e-mail)'),
                value: deletePersonalData,
                onChanged: (value) {
                  setState(() {
                    deletePersonalData = value ?? false;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Sempre revogar marketing
                await SharedPreferencesService.setMarketingConsent(false);
                String message = 'Consentimento de marketing revogado.';
                if (deletePersonalData) {
                  await SharedPreferencesService.removeUserName();
                  await SharedPreferencesService.removeUserEmail();
                  message += ' Dados pessoais apagados.';
                  // Navegar para Onboarding após apagar dados
                  Navigator.of(context).pop(); // fechar diálogo
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const OnboardingPage(),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
                // Recarregar dados se não navegou
                _loadUserData();
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await SharedPreferencesService.setOnboardingDone(false);
    await SharedPreferencesService.removeUserName();
    await SharedPreferencesService.removeUserEmail();
    await SharedPreferencesService.setMarketingConsent(false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReadSprint'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName ?? 'Nome não definido'),
              accountEmail: Text(_userEmail ?? 'E-mail não definido'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: kIsWeb
                    ? (_profileImageBytes != null
                        ? MemoryImage(_profileImageBytes!)
                        : null)
                    : (_profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null),
                child: (_profileImagePath == null && _profileImageBytes == null)
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              decoration: const BoxDecoration(color: Color(0xFF6A0DAD)),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    )
                    .then((_) => _loadUserData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidade & Consentimentos'),
              onTap: _showPrivacyDialog,
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _sprints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhum sprint criado ainda.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showCreateSprintDialog,
                    child: const Text('Novo Sprint'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _sprints.length + 1,
              itemBuilder: (context, index) {
                if (index < _sprints.length) {
                  final sprint = _sprints[index];
                  return SprintCard(
                    sprint: sprint,
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SprintDetailsPage(
                            sprint: sprint,
                            onSprintEnded: (endedSprint) {
                              setState(() {
                                _sprints.remove(endedSprint);
                              });
                            },
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _showCreateSprintDialog,
                        child: const Text('Novo Sprint'),
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
