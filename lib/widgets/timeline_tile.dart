import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/custody_event.dart';
import '../theme/app_theme.dart';

class CustodyTimelineTile extends StatelessWidget {
  CustodyTimelineTile({
    super.key,
    required this.event,
    required this.isFirst,
    required this.isLast,
  });

  final CustodyEvent event;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy • HH:mm');
    final dotColor = event.conditionsOk ? AppColors.success : AppColors.danger;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 6,
                  color: isFirst ? Colors.transparent : AppColors.border,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.35),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppColors.border,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${event.fromEntity}  →  ${event.toEntity}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.ink,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '${dateFmt.format(event.timestamp)} · ${event.location}',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        event.conditionsOk ? Icons.verified_outlined : Icons.warning_amber_rounded,
                        size: 14,
                        color: dotColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        event.conditionsOk ? 'Conditions verified' : 'Condition breach flagged',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: dotColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tx ${_shorten(event.txHash)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shorten(String hash) {
    if (hash.length <= 14) return hash;
    return '${hash.substring(0, 8)}…${hash.substring(hash.length - 6)}';
  }
}
