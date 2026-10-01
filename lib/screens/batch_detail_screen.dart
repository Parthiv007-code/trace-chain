import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/batch.dart';
import '../models/batch_status.dart';
import '../models/user_role.dart';
import '../theme/app_theme.dart';
import '../widgets/sensor_line_chart.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';
import '../widgets/timeline_tile.dart';

/// Read view of a single batch. Reused by every role — what actions are
/// offered below the record (transfer custody, flag recall) is controlled
/// by [actions], so this screen itself stays purely presentational.
class BatchDetailScreen extends StatelessWidget {
  BatchDetailScreen({
    super.key,
    required this.batch,
    this.actions,
  });

  final Batch batch;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(batch.id, style: TextStyle(fontFamily: 'monospace', fontSize: 15)),
      ),
      body: BatchDetailBody(batch: batch, actions: actions),
    );
  }
}

/// The scrollable content of a batch record, factored out so it can be
/// embedded inside a different Scaffold/AppBar (see [VerifyResultScreen])
/// without nesting a second full Scaffold.
class BatchDetailBody extends StatelessWidget {
  BatchDetailBody({super.key, required this.batch, this.actions});

  final Batch batch;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');

    return ListView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          if (batch.status == BatchStatus.recalled)
            _RecallBanner(reason: batch.recallReason)
          else if (batch.recallFlagged)
            _RecallFlagBanner(
              reason: batch.recallFlagReason,
              flaggedBy: batch.recallFlaggedBy,
              flaggedByRole: batch.recallFlaggedByRole,
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(batch.productName,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    SizedBox(height: 4),
                    Text(batch.category, style: TextStyle(color: AppColors.inkMuted, fontSize: 13)),
                  ],
                ),
              ),
              StatusBadge(status: batch.status),
            ],
          ),
          SizedBox(height: 20),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(label: 'Current holder', value: batch.currentHolderName),
                  _InfoRow(label: 'Origin', value: batch.originLocation),
                  _InfoRow(label: 'Manufacturer', value: batch.manufacturerName),
                  _InfoRow(
                    label: 'Registered',
                    value: dateFmt.format(batch.registeredAt),
                    isLast: batch.rawMaterials.isEmpty,
                  ),
                  if (batch.rawMaterials.isNotEmpty)
                    _InfoRow(
                      label: 'Raw materials',
                      value: batch.rawMaterials.join(', '),
                      isLast: true,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24),

          SectionHeader(title: 'Condition history', icon: Icons.thermostat_outlined),
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 16, 16, 8),
              child: batch.sensorEvents.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('No sensor readings recorded yet.',
                          style: TextStyle(color: AppColors.inkMuted, fontSize: 12.5)),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SensorLineChart(events: batch.sensorEvents),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _ReadingChip(
                              icon: Icons.thermostat_outlined,
                              label: '${batch.lastSensorReading!.temperatureC.toStringAsFixed(1)}°C',
                            ),
                            _ReadingChip(
                              icon: Icons.water_drop_outlined,
                              label: '${batch.lastSensorReading!.humidityPct.toStringAsFixed(0)}% RH',
                            ),
                            _ReadingChip(
                              icon: Icons.place_outlined,
                              label: batch.lastSensorReading!.location,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 24),

          SectionHeader(title: 'Chain of custody', icon: Icons.timeline_outlined),
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: batch.custodyHistory.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Still with the manufacturer — no transfers yet.',
                          style: TextStyle(color: AppColors.inkMuted, fontSize: 12.5)),
                    )
                  : Column(
                      children: List.generate(batch.custodyHistory.length, (i) {
                        return CustodyTimelineTile(
                          event: batch.custodyHistory[i],
                          isFirst: i == 0,
                          isLast: i == batch.custodyHistory.length - 1,
                        );
                      }),
                    ),
            ),
          ),
          SizedBox(height: 24),

          SectionHeader(title: 'Documents (IPFS)', icon: Icons.description_outlined),
          if (batch.documents.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No supporting documents uploaded.',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 12.5)),
              ),
            )
          else
            ...batch.documents.map((doc) => Card(
                  margin: EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(Icons.picture_as_pdf_outlined, color: AppColors.accent),
                    title: Text(doc.name, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'CID ${doc.ipfsHash.substring(0, 14)}… · uploaded by ${doc.uploadedBy}',
                      style: TextStyle(fontSize: 11.5, fontFamily: 'monospace'),
                    ),
                  ),
                )),
          SizedBox(height: 24),

          SectionHeader(title: 'Consumer verification QR', icon: Icons.qr_code_2_outlined),
          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  QrImageView(
                    data: batch.id,
                    size: 160,
                    backgroundColor: Colors.white,
                    version: QrVersions.auto,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Scanning this code runs verifyProduct("${batch.id}") — '
                    'a read-only chaincode query returning this exact history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          if (actions != null && actions!.isNotEmpty) ...[
            SizedBox(height: 28),
            ...actions!,
          ],
        ],
    );
  }
}

class _RecallFlagBanner extends StatelessWidget {
  _RecallFlagBanner({this.reason, this.flaggedBy, this.flaggedByRole});

  final String? reason;
  final String? flaggedBy;
  final UserRole? flaggedByRole;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withOpacity(.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flag_outlined, color: AppColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recall flagged — awaiting regulator review',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning, fontSize: 13.5),
                ),
                if (flaggedBy != null) ...[
                  SizedBox(height: 3),
                  Text(
                    'Flagged by $flaggedBy${flaggedByRole == null ? '' : ' · ${flaggedByRole!.label}'}',
                    style: TextStyle(fontSize: 11.5, color: AppColors.inkMuted),
                  ),
                ],
                if (reason != null) ...[
                  SizedBox(height: 4),
                  Text(reason!, style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecallBanner extends StatelessWidget {
  _RecallBanner({this.reason});
  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.report_gmailerrorred_outlined, color: AppColors.danger, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This batch has been recalled',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.danger, fontSize: 13.5)),
                if (reason != null) ...[
                  SizedBox(height: 3),
                  Text(reason!, style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.4)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  _InfoRow({required this.label, required this.value, this.isLast = false});
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12.5, color: AppColors.inkMuted)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
          ),
        ],
      ),
    );
  }
}

class _ReadingChip extends StatelessWidget {
  _ReadingChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.inkMuted),
          SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
