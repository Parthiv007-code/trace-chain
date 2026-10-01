import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ArchitectureScreen extends StatelessWidget {
  ArchitectureScreen({super.key});

  static final List<(String, IconData, String)> _layers = [
    (
      'Physical / IoT layer',
      Icons.sensors_outlined,
      'Simulated sensors emit temperature, humidity and location readings '
          'at each leg of a shipment\'s journey.'
    ),
    (
      'Oracle layer',
      Icons.satellite_alt_outlined,
      'A signing bridge reads sensor data and writes it on-chain as a '
          'signed event — the ledger trusts the oracle\'s signature, never '
          'the device directly.'
    ),
    (
      'Blockchain layer — Hyperledger Fabric',
      Icons.hub_outlined,
      'Chaincode enforces who can register a batch, who can transfer '
          'custody, and under what conditions, storing only state '
          'transitions and hashes.'
    ),
    (
      'Application layer',
      Icons.devices_outlined,
      'This Flutter app — a DApp interface for every stakeholder plus a '
          'consumer-facing QR verification flow.'
    ),
  ];

  static final List<(String, String)> _functions = [
    ('registerBatch()', 'Manufacturer registers a new batch, linked to its raw materials.'),
    ('transferCustody()', 'Moves custody between entities, subject to preconditions.'),
    ('recordSensorEvent()', 'Oracle logs a condition reading (temperature, humidity, location).'),
    ('verifyProduct()', 'Read-only consumer QR flow returning full provenance history.'),
    ('flagRecall()', 'Distributor or retailer reports a suspected issue for regulator review; it does not itself recall the batch.'),
    ('recallBatch()', 'Regulator reviews an active recall flag and executes the actual recall.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('System Architecture')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Text(
              'Recommended ledger: Hyperledger Fabric (permissioned), with '
              'periodic state-hash anchoring to public Ethereum for '
              'independent external validation. Chosen for known '
              'participants, business confidentiality, predictable cost, '
              'and regulator-identifiable transactions.',
              style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.ink),
            ),
          ),
          SizedBox(height: 24),
          Text('Four layers', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 12),
          ..._layers.map((l) => _LayerTile(title: l.$1, icon: l.$2, description: l.$3)),
          SizedBox(height: 12),
          Text('Chaincode functions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: _functions
                    .map((f) => Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.bolt_outlined, size: 16, color: AppColors.accent),
                              SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(fontSize: 13, color: AppColors.ink, height: 1.4),
                                    children: [
                                      TextSpan(
                                        text: '${f.$1}  ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      TextSpan(text: f.$2, style: TextStyle(color: AppColors.inkMuted)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.construction_outlined, color: AppColors.warning, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current milestone: complete frontend against a mock '
                    'ledger service matching this exact interface. Next '
                    'milestone: deploy the Fabric network and chaincode, '
                    'then swap the mock service for a real one.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  _LayerTile({required this.title, required this.icon, required this.description});

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  SizedBox(height: 3),
                  Text(description,
                      style: TextStyle(fontSize: 12, color: AppColors.inkMuted, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
