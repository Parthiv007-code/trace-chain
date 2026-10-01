import '../models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch.dart';
import '../models/batch_status.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/batch_card.dart';
import '../widgets/empty_state.dart';
import 'batch_detail_screen.dart';
import 'recall_screen.dart';

class RegulatorDashboard extends StatefulWidget {
  RegulatorDashboard({super.key});

  @override
  State<RegulatorDashboard> createState() => _RegulatorDashboardState();
}

class _RegulatorDashboardState extends State<RegulatorDashboard> {
  BatchStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final all = state.batchesForCurrentRole();
    final breaches = all.where((b) => b.hasConditionBreach).length;
    final flagged = all.where((b) => b.recallFlagged && b.status != BatchStatus.recalled).length;
    final recalled = all.where((b) => b.status == BatchStatus.recalled).length;
    final visible = _filter == null ? all : all.where((b) => b.status == _filter).toList();

    return RefreshIndicator(
      onRefresh: state.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Total on ledger', value: '${all.length}', icon: Icons.storage_outlined, color: AppColors.primary)),
              SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Condition breaches', value: '$breaches', icon: Icons.warning_amber_rounded, color: AppColors.warning)),
              SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Recall flags', value: '$flagged', icon: Icons.flag_outlined, color: AppColors.warning)),
              SizedBox(width: 12),
              Expanded(child: _StatTile(label: 'Recalled', value: '$recalled', icon: Icons.report_gmailerrorred_outlined, color: AppColors.danger)),
            ],
          ),
          SizedBox(height: 22),
          Text('All batches', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
          SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(label: 'All', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                for (final s in BatchStatus.values)
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: _FilterChip(label: s.label, selected: _filter == s, onTap: () => setState(() => _filter = s)),
                  ),
              ],
            ),
          ),
          SizedBox(height: 14),
          if (state.isLoading && all.isEmpty)
            Padding(padding: EdgeInsets.only(top: 40), child: Center(child: CircularProgressIndicator()))
          else if (visible.isEmpty)
            EmptyState(icon: Icons.filter_alt_off_outlined, title: 'No batches match this filter', message: 'Try a different status filter.')
          else
            ...visible.map((b) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: BatchCard(batch: b, onTap: () => _openBatch(context, b)),
                )),
        ],
      ),
    );
  }

  void _openBatch(BuildContext context, Batch batch) {
    final actions = <Widget>[];

    if (batch.status == BatchStatus.recalled) {
      // Already resolved.
    } else if (batch.recallFlagged) {
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
              Icon(Icons.flag_outlined, color: AppColors.warning, size: 19),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recall flag awaiting review', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    SizedBox(height: 4),
                    Text(
                      'Flagged by ${batch.recallFlaggedBy ?? 'stakeholder'} · ${batch.recallFlaggedByRole?.label ?? 'Stakeholder'}',
                      style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
                    ),
                    if (batch.recallFlagReason != null) ...[
                      SizedBox(height: 6),
                      Text(batch.recallFlagReason!, style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      actions.add(SizedBox(height: 10));
      actions.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecallScreen(batch: batch))),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            icon: Icon(Icons.gavel_outlined, size: 18),
            label: Text('Review & Recall Batch'),
          ),
        ),
      );
    } else {
      actions.add(
        Container(
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(.16)),
          ),
          child: Text(
            'No active recall flag. A distributor or retailer must flag a suspected issue before a regulator can execute a recall.',
            style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
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

class _FilterChip extends StatelessWidget {
  _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withOpacity(0.14),
      labelStyle: TextStyle(color: selected ? AppColors.primary : AppColors.ink, fontWeight: FontWeight.w600, fontSize: 12.5),
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
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.inkMuted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
