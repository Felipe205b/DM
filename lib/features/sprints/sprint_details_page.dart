import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sprint_provider.dart';
import '../models/book.dart';
import 'sprint.dart';
import '../home/home_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../services/shared_preferences_services.dart';

final sprintProvider =
    ChangeNotifierProvider.family<SprintProvider, Book>((ref, book) {
  final homeNotifier = ref.read(homeProvider);
  return SprintProvider(homeNotifier, book);
});

class SprintDetailsPage extends ConsumerStatefulWidget {
  final Book book;

  const SprintDetailsPage({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<SprintDetailsPage> createState() => _SprintDetailsPageState();
}

class _SprintDetailsPageState extends ConsumerState<SprintDetailsPage> {
  final GlobalKey _progressKey = GlobalKey();
  final GlobalKey _dailyGoalKey = GlobalKey();
  final GlobalKey _editKey = GlobalKey();
  final GlobalKey _deleteKey = GlobalKey();
  bool _isTutorialInitiated = false;

  @override
  void initState() {
    super.initState();
  }

  void _checkAndShowTutorial(BuildContext context) {
    SharedPreferencesService.getTutorialStep().then((tutorialStep) {
      if (tutorialStep == 4) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowCaseWidget.of(context).startShowCase(
            [_progressKey, _dailyGoalKey, _editKey, _deleteKey],
          );
        });
      }
    });
  }

  void _showEditSprintDialog(Sprint sprint) {
    final pagesController =
        TextEditingController(text: sprint.totalPages.toString());
    final durationController =
        TextEditingController(text: sprint.durationInDays.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Sprint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                final newTotalPages = int.tryParse(pagesController.text) ?? 0;
                final newDurationInDays =
                    int.tryParse(durationController.text) ?? 0;

                if (newTotalPages > 0 && newDurationInDays > 0) {
                  final updatedBook = widget.book.copyWith(
                    totalPages: newTotalPages,
                    daysToRead: newDurationInDays,
                    pagesRead: 0,
                    daysRead: 0,
                    dailyProgress: List.filled(newDurationInDays, false),
                  );
                  ref.read(homeProvider).updateBook(updatedBook);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);

    return booksAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erro: $error')),
      ),
      data: (books) {
        final currentBook = books.firstWhere(
          (b) => b.id == widget.book.id,
          orElse: () => widget.book,
        );

        final sprint = ref.watch(sprintProvider(currentBook)).sprint;

        if (sprint == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return ShowCaseWidget(
          onFinish: () {
            SharedPreferencesService.setTutorialStep(0);
          },
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text(sprint.title),
              ),
              body: Builder(
                builder: (context) {
                  if (!_isTutorialInitiated) {
                    _isTutorialInitiated = true;
                    _checkAndShowTutorial(context);
                  }
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Showcase(
                          key: _progressKey,
                          description:
                              'Aqui você pode acompanhar o progresso do seu sprint',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progresso: ${(sprint.progress * 100).toStringAsFixed(0)}% - Restam ${sprint.remainingDays} dias',
                              ),
                              const SizedBox(height: 8.0),
                              LinearProgressIndicator(
                                value: sprint.progress,
                                minHeight: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Showcase(
                          key: _dailyGoalKey,
                          description:
                              'Marque aqui as metas diárias que você já concluiu',
                          child: Text(
                            'Metas Diárias:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: sprint.durationInDays,
                            itemBuilder: (context, index) {
                              final pagesForDay = sprint.getPagesForDay(index);
                              final isEnabled = (index == 0 &&
                                      !currentBook.dailyProgress[index]) ||
                                  (index > 0 &&
                                      currentBook.dailyProgress[index - 1] &&
                                      !currentBook.dailyProgress[index]) ||
                                  (currentBook.dailyProgress[index] &&
                                      (index ==
                                              currentBook
                                                  .dailyProgress.length -
                                                  1 ||
                                          !currentBook
                                              .dailyProgress[index + 1]));

                              return CheckboxListTile(
                                title: Text(
                                    'Dia ${index + 1}: Ler $pagesForDay páginas'),
                                value: currentBook.dailyProgress[index],
                                onChanged: isEnabled
                                    ? (bool? value) {
                                        if (value != null) {
                                          ref
                                              .read(sprintProvider(currentBook))
                                              .updateSprintProgress(
                                                  index, value);
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Showcase(
                              key: _editKey,
                              description:
                                  'Clique aqui para editar as metas do seu sprint',
                              child: ElevatedButton(
                                onPressed: () => _showEditSprintDialog(sprint),
                                child: const Text('Editar metas'),
                              ),
                            ),
                            Showcase(
                              key: _deleteKey,
                              description:
                                  'Clique aqui para deletar o seu sprint',
                              child: ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(sprintProvider(currentBook))
                                      .deleteSprint();
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Deletar sprint'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
