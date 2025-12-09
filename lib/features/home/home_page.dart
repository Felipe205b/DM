import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/shared_preferences_services.dart';
import '../models/book.dart';
import '../sprints/sprint_card.dart';
import '../sprints/sprint_details_page.dart';
import 'home_provider.dart';
import '../sprints/sprint.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:uuid/uuid.dart';
import '../app/theme_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  static const routeName = '/home';

  const HomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _CreateSprintDialog extends ConsumerStatefulWidget {
  const _CreateSprintDialog();

  @override
  ConsumerState<_CreateSprintDialog> createState() =>
      __CreateSprintDialogState();
}

class __CreateSprintDialogState extends ConsumerState<_CreateSprintDialog> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _durationController = TextEditingController();
  final _titleKey = GlobalKey();
  final _pagesKey = GlobalKey();
  final _durationKey = GlobalKey();
  final _createKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }

  void _checkAndShowTutorial() {
    SharedPreferencesService.getTutorialStep().then((tutorialStep) {
      if (tutorialStep == 2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowcaseView.get().startShowCase(
            [_titleKey, _pagesKey, _durationKey, _createKey],
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pagesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo Sprint'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Showcase(
            key: _titleKey,
            description: 'Insira o título do material de leitura',
            child: TextField(
              controller: _titleController,
              decoration:
                  const InputDecoration(labelText: 'Título do material'),
            ),
          ),
          TextField(
            controller: _authorController,
            decoration: const InputDecoration(labelText: 'Autor'),
          ),
          Showcase(
            key: _pagesKey,
            description: 'Insira o total de páginas',
            child: TextField(
              controller: _pagesController,
              decoration: const InputDecoration(labelText: 'Total de páginas'),
              keyboardType: TextInputType.number,
            ),
          ),
          Showcase(
            key: _durationKey,
            description: 'Insira a duração em dias',
            child: TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duração (dias)'),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        Showcase(
          key: _createKey,
          description: 'Clique aqui para criar o sprint',
          child: ElevatedButton(
            onPressed: () async {
              final title = _titleController.text;
              final author = _authorController.text;
              final totalPages = int.tryParse(_pagesController.text) ?? 0;
              final durationInDays =
                  int.tryParse(_durationController.text) ?? 0;

              // Capture o navigator e o scaffoldMessenger antes do await
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              if (title.isNotEmpty &&
                  author.isNotEmpty &&
                  totalPages > 0 &&
                  durationInDays > 0) {
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Erro: Usuário não autenticado.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                try {
                  await SharedPreferencesService.setTutorialStep(3);
                  final book = Book(
                    id: const Uuid().v4(),
                    userId: user.id,
                    title: title,
                    author: author,
                    totalPages: totalPages,
                  );
                  await ref
                      .read(homeProvider)
                      .createSprint(book, durationInDays);
                  navigator.pop(true);
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro ao criar sprint: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Criar Sprint'),
          ),
        ),
      ],
    );
  }
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _userName;
  String? _userEmail;
  String? _profileImagePath;
  final GlobalKey _novoSprintKey = GlobalKey();
  final GlobalKey _verDetalhesKey = GlobalKey();
  bool _isTutorialInitiated = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    ShowcaseView.register(
      onComplete: (index, key) {
        if (key == _novoSprintKey) {
          SharedPreferencesService.setTutorialStep(2);
          _showCreateSprintDialog();
        }
      },
    );
  }

  @override
  void dispose() {
    ShowcaseView.get().unregister();
    super.dispose();
  }

  void _checkAndShowTutorial(BuildContext context) {
    SharedPreferencesService.getTutorialStep().then((tutorialStep) {
      if (tutorialStep == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowcaseView.get().startShowCase([_novoSprintKey]);
        });
      } else if (tutorialStep == 3) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowcaseView.get().startShowCase([_verDetalhesKey]);
        });
      }
    });
  }

  Future<void> _loadUser() async {
    final name = await SharedPreferencesService.getUserName();
    final email = await SharedPreferencesService.getUserEmail();
    final imagePath = await SharedPreferencesService.getProfileImagePath();
    if (!mounted) return;
    setState(() {
      _userName = name;
      _userEmail = email;
      _profileImagePath = imagePath;
    });
  }

  Future<void> _showCreateSprintDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const _CreateSprintDialog(),
    );

    if (created == true) {
      final tutorialStep = await SharedPreferencesService.getTutorialStep();
      if (!mounted) return;
      if (tutorialStep == 3) {
        _checkAndShowTutorial(context);
      }
    }
  }

  Future<void> _revokeConsents() async {
    final navigator = Navigator.of(context);
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

    navigator.pushReplacementNamed('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final brightness = MediaQuery.platformBrightnessOf(context);
    final themeMode = ref.watch(themeControllerProvider).value;

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && brightness == Brightness.dark);

    return Scaffold(
          appBar: AppBar(
            title: const Text('ReadSprint'),
          ),
          drawer: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(_userName ?? 'Usuário não registrado'),
                  accountEmail: Text(_userEmail ?? ''),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: _profileImagePath != null
                        ? (kIsWeb
                            ? MemoryImage(base64Decode(_profileImagePath!))
                            : FileImage(File(_profileImagePath!)))
                                as ImageProvider
                        : null,
                    child: _profileImagePath == null
                        ? Text(
                            _userName != null && _userName!.isNotEmpty
                                ? _userName!
                                    .trim()
                                    .split(' ')
                                    .map((e) => e.isNotEmpty ? e[0] : '')
                                    .take(2)
                                    .join()
                                : '?',
                            style: const TextStyle(fontSize: 20),
                          )
                        : null,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Editar perfil'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final result = await Navigator.of(
                      context,
                    ).pushNamed('/profile');
                    if (result == true) {
                      _loadUser();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Revogar Consentimentos'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _revokeConsents();
                  },
                ),
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                  ),
                  title: const Text('Tema escuro'),
                  subtitle: Text(
                    themeMode == ThemeMode.system
                        ? 'Seguindo o sistema'
                        : (isDark ? 'Ativado' : 'Desativado'),
                  ),
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeControllerProvider.notifier).toggle(brightness);
                  },
                ),
              ],
            ),
          ),
          body: Builder(
            builder: (context) {
              return booksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('Erro: $error')),
                data: (books) {
                  if (!_isTutorialInitiated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _checkAndShowTutorial(context);
                    });
                    _isTutorialInitiated = true;
                  }
                  return books.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Nenhum sprint criado ainda.'),
                              const SizedBox(height: 16),
                              Showcase(
                                key: _novoSprintKey,
                                description:
                                    'Clique aqui para criar um novo sprint',
                                child: ElevatedButton(
                                  onPressed: _showCreateSprintDialog,
                                  child: const Text('Novo Sprint'),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: books.length + 1,
                          itemBuilder: (context, index) {
                            if (index < books.length) {
                              final book = books[index];
                              return Consumer(
                                builder: (context, ref, child) {
                                  final readingProgressAsync = ref.watch(
                                      readingProgressProvider(book.id));
                                  return readingProgressAsync.when(
                                    loading: () => const Center(
                                        child: CircularProgressIndicator()),
                                    error: (error, stack) =>
                                        Center(child: Text('Erro: $error')),
                                    data: (readingProgress) {
                                      if (readingProgress == null) {
                                        return const ListTile(
                                          title: Text(
                                              'Erro ao carregar progresso'),
                                        );
                                      }
                                      final sprint = Sprint(
                                        title: book.title,
                                        totalPages: book.totalPages,
                                        durationInDays:
                                            readingProgress.durationInDays,
                                        pagesRead: readingProgress.pagesRead,
                                        daysRead: readingProgress.daysRead,
                                      );
                                      return SprintCard(
                                        sprint: sprint,
                                        showcaseKey: index == 0
                                            ? _verDetalhesKey
                                            : null,
                                        onViewDetails: () async {
                                          final navigator = Navigator.of(context);
                                          final tutorialStep =
                                              await SharedPreferencesService
                                                  .getTutorialStep();
                                          if (tutorialStep == 3) {
                                            await SharedPreferencesService
                                                .setTutorialStep(4);
                                          }
                                          if (!mounted) return;
                                          navigator.push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SprintDetailsPage(
                                                book: book,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Showcase(
                                    key: _novoSprintKey,
                                    description:
                                        'Clique aqui para criar um novo sprint',
                                    child: ElevatedButton(
                                      onPressed: _showCreateSprintDialog,
                                      child: const Text('Novo Sprint'),
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                },
              );
            },
          ),
        );
  }
}
