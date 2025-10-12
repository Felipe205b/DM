import 'package:flutter/material.dart';
import 'sprint.dart';

class SprintDetailsPage extends StatefulWidget {
  final Sprint sprint;
  final Function(Sprint) onSprintEnded;

  const SprintDetailsPage({
    super.key,
    required this.sprint,
    required this.onSprintEnded,
  });

  @override
  State<SprintDetailsPage> createState() => _SprintDetailsPageState();
}

class _SprintDetailsPageState extends State<SprintDetailsPage> {
  void _showEditSprintDialog() {
    final pagesController =
        TextEditingController(text: widget.sprint.totalPages.toString());
    final durationController =
        TextEditingController(text: widget.sprint.durationInDays.toString());

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
                  setState(() {
                    widget.sprint.updateGoals(
                      newTotalPages: newTotalPages,
                      newDurationInDays: newDurationInDays,
                    );
                  });
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sprint.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metas Diárias:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.sprint.durationInDays,
                itemBuilder: (context, index) {
                  final pagesForDay = widget.sprint.getPagesForDay(index);
                  return CheckboxListTile(
                    title: Text('Dia ${index + 1}: Ler $pagesForDay páginas'),
                    value: widget.sprint.dailyGoals[index],
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          // Logic to check a day
                          bool canCheck = index == 0 || widget.sprint.dailyGoals[index - 1];
                          if (canCheck) {
                            widget.sprint.dailyGoals[index] = true;
                            widget.sprint.pagesRead += pagesForDay;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Complete os dias anteriores para marcar este como concluído.'),
                              ),
                            );
                          }
                        } else {
                          // Logic to uncheck a day
                          for (int i = index; i < widget.sprint.durationInDays; i++) {
                            if (widget.sprint.dailyGoals[i]) {
                              widget.sprint.dailyGoals[i] = false;
                              widget.sprint.pagesRead -= widget.sprint.getPagesForDay(i);
                            }
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showEditSprintDialog,
                  child: const Text('Editar metas'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSprintEnded(widget.sprint);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Encerrar sprint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}