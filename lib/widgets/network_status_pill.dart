import 'package:flutter/material.dart';

class NetworkStatusPill extends StatelessWidget {
  const NetworkStatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _showInfo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.amber.withOpacity(.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, size: 7, color: Colors.amber),
            const SizedBox(width: 6),
            Text(
              'TESTNET',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .8, color: scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.hub_outlined, color: Colors.teal, size: 28),
            const SizedBox(height: 12),
            Text('Ledger connection', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'This build runs against the mock ledger service. Its service interface mirrors the production chain functions, so the UI can remain unchanged when the real network is connected.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
