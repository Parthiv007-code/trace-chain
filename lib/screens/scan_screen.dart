import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'verify_result_screen.dart';

/// A simulated scan experience: since there is no blockchain backend to
/// scan against yet, this screen offers demo batches to "scan" instead of
/// requesting camera permissions for a network call that doesn't exist.
/// Swapping in a real camera (e.g. the mobile_scanner package) once the
/// ledger is live only touches this one file.
class ScanScreen extends StatefulWidget {
  ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _simulateScan(String batchId) async {
    setState(() => _isVerifying = true);
    final Batch? batch = await context.read<AppState>().verifyProduct(batchId);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (batch == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VerifyResultScreen(batch: batch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final demoBatches = state.batches.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        title: Text('Scan QR Code', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Positioned(
                        top: 10 + _controller.value * 220,
                        child: Container(
                          width: 230,
                          height: 2,
                          color: AppColors.accent,
                        ),
                      );
                    },
                  ),
                  if (_isVerifying)
                    CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Camera not connected in this build',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap a demo product below to simulate scanning its QR code.',
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
                SizedBox(height: 14),
                ...demoBatches.map((b) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.qr_code_2_outlined, color: AppColors.primary),
                        title: Text(b.productName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text(b.id, style: TextStyle(fontSize: 11, fontFamily: 'monospace')),
                        onTap: _isVerifying ? null : () => _simulateScan(b.id),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
