import 'package:flutter/material.dart';
import '../../services/shared_preferences_services.dart';
import '../sprints/sprint.dart';
import '../sprints/sprint_card.dart';
import '../sprints/sprint_details_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Sprint> _sprints = [];

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

  Future<void> _revokeConsents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revogar Consentimentos'),
        content: const Text(
          'Tem certeza que deseja revogar todos os consentimentos e voltar para a tela de boas-vindas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Revogar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await SharedPreferencesService.removeAll();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ReadSprint'),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _revokeConsents,
        label: const Text('Revogar Consentimento'),
        icon: const Icon(Icons.delete),
      ),
    );
  }
}
