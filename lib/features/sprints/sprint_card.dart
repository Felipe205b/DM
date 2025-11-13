import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'sprint.dart';

class SprintCard extends StatelessWidget {
  final Sprint sprint;
  final VoidCallback onViewDetails;
  final GlobalKey? showcaseKey;

  const SprintCard({
    super.key,
    required this.sprint,
    required this.onViewDetails,
    this.showcaseKey,
  });

  @override
  Widget build(BuildContext context) {
    final detailsButton = ElevatedButton(
      onPressed: onViewDetails,
      child: const Text('Ver detalhes'),
    );

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
              child: showcaseKey != null
                  ? Showcase(
                      key: showcaseKey!,
                      description: 'Clique aqui para ver os detalhes do sprint',
                      child: detailsButton,
                    )
                  : detailsButton,
            ),
          ],
        ),
      ),
    );
  }
}