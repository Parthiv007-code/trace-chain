import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/batch.dart';
import '../models/batch_status.dart';
import 'status_badge.dart';

class BatchCard extends StatelessWidget {
  const BatchCard({super.key, required this.batch, required this.onTap});
  final Batch batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 15, 14, 15),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 62,
                decoration: BoxDecoration(
                  color: batch.status.color,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.productName,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch.id,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .6,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            batch.currentHolderName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.event_outlined, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          dateFmt.format(batch.registeredAt),
                          style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: batch.status),
                  if (batch.sensorEvents.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      '${batch.lastSensorReading!.temperatureC.toStringAsFixed(1)}°C',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
