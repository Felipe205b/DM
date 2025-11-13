import 'package:flutter/material.dart';

import '../../services/shared_preferences_services.dart';
import 'policy_viewer_page.dart';

class ListtilePolicyWidget extends StatefulWidget {
  final bool isPrivacyPolicyRead;
  final String assetPath;
  final String policyTitle;
  final VoidCallback onPolicyRead;

  const ListtilePolicyWidget({
    super.key,
    required this.isPrivacyPolicyRead,
    required this.assetPath,
    required this.policyTitle,
    required this.onPolicyRead,
  });

  @override
  State<ListtilePolicyWidget> createState() => _ListtilePolicyWidgetState();
}

class _ListtilePolicyWidgetState extends State<ListtilePolicyWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        widget.isPrivacyPolicyRead ? Icons.check_circle : Icons.cancel,
        color: widget.isPrivacyPolicyRead ? Colors.green : Colors.red,
      ),
      title: Text(widget.policyTitle),
      trailing: TextButton(
        onPressed: widget.isPrivacyPolicyRead
            ? null
            : () async {
                final value = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return PolicyViewerPage(
                        policyTitle: widget.policyTitle,
                        assetPath: widget.assetPath,
                      );
                    },
                  ),
                );
                bool didRead = value ?? false;

                await SharedPreferencesService.setPrivacyPolicyAllRead(didRead);
                if (didRead) {
                  widget.onPolicyRead();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Obrigado por aceitar a ${widget.policyTitle}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
        child: Text(widget.isPrivacyPolicyRead ? 'Lido' : 'Ler'),
      ),
    );
  }
}
