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
import 'recall_screen.dart';
import 'transfer_custody_screen.dart';

/// Distributor and retailer workspace. Both can flag a suspected recall,
/// but neither role can execute the actual recall.
class HandlerDashboard extends StatelessWidget {
  HandlerDashboard({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final batches = state.batchesForCurrentRole();
    final inTransit = batches.where((b) => b.status == BatchStatus.inTransit).length;
    final flags = batches.where((b) => b.recallFlagged).length;

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'In custody',
                  value: '${batches.length}',
                  icon: Icons.inventory_2_outlined,
                  color: role.color,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'In transit',
                  value: '$inTransit',
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.warning,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Recall flags',
                  value: '$flags',
                  icon: Icons.flag_outlined,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            'Batches with ${state.currentUserName}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
          ),
          SizedBox(height: 12),
          if (state.isLoading && batches.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (batches.isEmpty)
            EmptyState(
              icon: role.icon,
              title: 'Nothing in custody',
              message: 'Batches transferred to you by an upstream partner will appear here.',
            )
          else
            ...batches.map(
              (b) => Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: BatchCard(
                  batch: b,
                  onTap: () => _openBatch(context, b),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openBatch(BuildContext context, Batch batch) {
    final isRecalled = batch.status == BatchStatus.recalled;
    final isFlagged = batch.recallFlagged;

    final actions = <Widget>[];

    if (isRecalled) {
      // No further custody or recall actions.
    } else if (isFlagged) {
      actions.add(
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.warning.withOpacity(.28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.hourglass_top_outlined, color: AppColors.warning, size: 19),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recall flag submitted. This batch is awaiting regulator review, so custody transfer is paused.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      actions.addAll([
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TransferCustodyScreen(batch: batch)),
            ),
            icon: Icon(Icons.sync_alt, size: 18),
            label: Text('Transfer Custody'),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => RecallScreen(batch: batch)),
            ),
            icon: Icon(Icons.flag_outlined, size: 18, color: AppColors.danger),
            label: Text('Flag Recall', style: TextStyle(color: AppColors.danger)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.danger),
            ),
          ),
        ),
      ]);
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
  _StatTile({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
            SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.inkMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
