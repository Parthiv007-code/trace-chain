import 'package:flutter/material.dart';

import '../models/batch.dart';
import '../models/batch_status.dart';
import '../theme/app_theme.dart';
import 'batch_detail_screen.dart';

class VerifyResultScreen extends StatelessWidget {
  VerifyResultScreen({super.key, required this.batch});

  final Batch batch;

  @override
  Widget build(BuildContext context) {
    final verified = batch.status != BatchStatus.recalled;
    return Scaffold(
      appBar: AppBar(title: Text('Verification Result')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
            color: verified ? AppColors.success.withOpacity(0.1) : AppColors.danger.withOpacity(0.08),
            child: Column(
              children: [
                Icon(
                  verified ? Icons.verified_rounded : Icons.report_gmailerrorred_rounded,
                  color: verified ? AppColors.success : AppColors.danger,
                  size: 46,
                ),
                SizedBox(height: 10),
                Text(
                  verified ? 'Provenance Verified' : 'This Batch Was Recalled',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: verified ? AppColors.success : AppColors.danger,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'verifyProduct("${batch.id}") returned ${batch.custodyHistory.length + 1} '
                  'on-chain event${batch.custodyHistory.length == 0 ? '' : 's'}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          Expanded(
            child: BatchDetailBody(batch: batch),
          ),
        ],
      ),
    );
  }
}
