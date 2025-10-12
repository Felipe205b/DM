import 'package:flutter/material.dart';
import 'sprint.dart';

class SprintCard extends StatelessWidget {
  final Sprint sprint;
  final VoidCallback onViewDetails;

  const SprintCard({
    super.key,
    required this.sprint,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sprint.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            LinearProgressIndicator(
              value: sprint.progress,
              minHeight: 10,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Progresso: ${(sprint.progress * 100).toStringAsFixed(0)}% - Restam ${sprint.remainingDays} dias',
            ),
            const SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onViewDetails,
                child: const Text('Ver detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}