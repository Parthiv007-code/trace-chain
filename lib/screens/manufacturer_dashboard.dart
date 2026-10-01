import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch.dart';
import '../models/batch_status.dart';
import '../models/user_role.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_card.dart';
import '../widgets/empty_state.dart';
import 'batch_detail_screen.dart';
import 'transfer_custody_screen.dart';

class ManufacturerDashboard extends StatelessWidget {
  ManufacturerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final batches = state.batchesForCurrentRole();

    final active =
        batches.where((b) => b.status != BatchStatus.recalled).length;

    final recalled =
        batches.where((b) => b.status == BatchStatus.recalled).length;

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Total batches',
                  value: '${batches.length}',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Active',
                  value: '$active',
                  icon: Icons.trending_up_outlined,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Recalled',
                  value: '$recalled',
                  icon: Icons.report_gmailerrorred_outlined,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Your batches',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
            ),
          ),

          const SizedBox(height: 12),

          if (state.isLoading && batches.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (batches.isEmpty)
            EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No batches yet',
              message:
                  'Tap "Register Batch" to record your first batch on the ledger.',
            )
          else
            ...batches.map(
              (batch) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BatchCard(
                  batch: batch,
                  onTap: () => _openBatch(context, batch),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openBatch(BuildContext context, Batch batch) {
    final actions = <Widget>[];

    if (batch.status == BatchStatus.recalled) {
      // Recalled batches cannot be transferred.
    } else if (batch.recallFlagged) {
      actions.add(
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.warning.withOpacity(.28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.hourglass_top_outlined,
                color: AppColors.warning,
                size: 19,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recall flag submitted. This batch is awaiting regulator review, so custody transfer is paused.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (batch.currentHolderRole == UserRole.manufacturer) {
      actions.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TransferCustodyScreen(
                    batch: batch,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.sync_alt,
              size: 18,
            ),
            label: const Text('Transfer Custody to Distributor'),
          ),
        ),
      );
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BatchDetailScreen(
          batch: batch,
          actions: actions.isEmpty ? null : actions,
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 10,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 18,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}