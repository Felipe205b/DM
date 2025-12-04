import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_safe/features/models/reading_progress.dart';
import 'sprint_provider.dart';
import '../models/book.dart';
import 'sprint.dart';
import '../home/home_provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../services/shared_preferences_services.dart';

class SprintProviderArgs {
  final Book book;
  final ReadingProgress readingProgress;

  SprintProviderArgs({required this.book, required this.readingProgress});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SprintProviderArgs &&
      other.book == book &&
      other.readingProgress == readingProgress;
  }

  @override
  int get hashCode => book.hashCode ^ readingProgress.hashCode;
}

final sprintProvider =
    ChangeNotifierProvider.family<SprintProvider, SprintProviderArgs>((ref, args) {
  final homeNotifier = ref.read(homeProvider);
  return SprintProvider(homeNotifier, args.book, args.readingProgress);
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

  void _showEditSprintDialog(Sprint sprint, ReadingProgress readingProgress) {
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
                  );
                  final updatedReadingProgress = ReadingProgress(
                    id: readingProgress.id,
                    bookId: readingProgress.bookId,
                    durationInDays: newDurationInDays,
                    pagesRead: 0,
                    daysRead: 0,
                  );
                  ref.read(homeProvider).updateBook(updatedBook);
                  ref.read(homeProvider).updateReadingProgress(updatedReadingProgress);
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
    final readingProgressAsync = ref.watch(readingProgressProvider(widget.book.id));

    return readingProgressAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Erro: $error')),
      ),
      data: (readingProgress) {
        if (readingProgress == null) {
          return const Scaffold(
            body: Center(
              child: Text('Erro ao carregar o progresso da leitura.'),
            ),
          );
        }

        final sprintNotifier = ref.watch(sprintProvider(SprintProviderArgs(book: widget.book, readingProgress: readingProgress)));
        final sprint = sprintNotifier.sprint;

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
                              final isEnabled = (index == sprint.daysRead) || (index == sprint.daysRead - 1 && index < sprint.daysRead);

                              return CheckboxListTile(
                                title: Text(
                                    'Dia ${index + 1}: Ler $pagesForDay páginas'),
                                value: index < sprint.daysRead,
                                onChanged: isEnabled
                                    ? (bool? value) {
                                        if (value != null) {
                                          sprintNotifier.updateSprintProgress(index, value);
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
                                onPressed: () => _showEditSprintDialog(sprint, readingProgress),
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
                                      .read(homeProvider)
                                      .deleteBook(widget.book);
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
