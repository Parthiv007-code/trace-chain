import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch.dart';
import '../models/user_role.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'batch_detail_screen.dart';

class RecallScreen extends StatefulWidget {
  RecallScreen({super.key, required this.batch});

  final Batch batch;

  @override
  State<RecallScreen> createState() => _RecallScreenState();
}

class _RecallScreenState extends State<RecallScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _reasonController;
  bool _isSubmitting = false;

  bool get _isRegulator =>
      context.read<AppState>().currentRole == UserRole.regulator;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(
      text: widget.batch.recallFlagReason ?? '',
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final regulator = _isRegulator;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(regulator ? 'Confirm recall' : 'Submit recall flag'),
        content: Text(
          regulator
              ? 'This will recall ${widget.batch.id} on the ledger. Further custody movement will remain blocked.'
              : 'This will flag ${widget.batch.id} for regulator review. The batch will not be recalled yet, but custody movement will pause.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(regulator ? 'Recall Batch' : 'Flag Recall'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final state = context.read<AppState>();
      final updated = regulator
          ? await state.recallBatch(
              batchId: widget.batch.id,
              reason: _reasonController.text.trim(),
            )
          : await state.flagRecall(
              batchId: widget.batch.id,
              reason: _reasonController.text.trim(),
            );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: updated)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final regulator = _isRegulator;

    return Scaffold(
      appBar: AppBar(
        title: Text(regulator ? 'Review Recall Flag' : 'Flag Recall'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withOpacity(.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.report_gmailerrorred_outlined, size: 18, color: AppColors.danger),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      regulator
                          ? 'A ${widget.batch.recallFlaggedByRole?.label ?? 'stakeholder'} flagged this batch. Review the report before executing the recall.'
                          : 'This creates a recall flag for the regulator. It is recorded on the ledger, but the batch is not recalled until a regulator reviews it.',
                      style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            if (regulator && widget.batch.recallFlagged) ...[
              SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recall flag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.inkMuted)),
                      SizedBox(height: 7),
                      Text(widget.batch.recallFlagReason ?? 'No reason supplied.', style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.4)),
                      if (widget.batch.recallFlaggedBy != null) ...[
                        SizedBox(height: 10),
                        Text(
                          'Flagged by ${widget.batch.recallFlaggedBy} · ${widget.batch.recallFlaggedByRole?.label ?? 'Stakeholder'}',
                          style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: 24),
            Text(
              regulator ? 'Recall reason / decision basis' : 'Reason for recall flag',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.inkMuted),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: regulator
                    ? 'Confirm the basis for the recall, or keep the stakeholder\'s reported reason.'
                    : 'e.g. Cold-chain breach detected — temperature exceeded 4°C for over 40 minutes in transit.',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                icon: _isSubmitting
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(regulator ? Icons.gavel_outlined : Icons.flag_outlined, size: 18),
                label: Text(
                  _isSubmitting
                      ? (regulator ? 'Recalling…' : 'Submitting flag…')
                      : (regulator ? 'Recall Batch' : 'Flag Recall'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
