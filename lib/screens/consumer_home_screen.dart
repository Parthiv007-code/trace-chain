import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'verify_result_screen.dart';

class ConsumerHomeScreen extends StatefulWidget {
  ConsumerHomeScreen({super.key});

  @override
  State<ConsumerHomeScreen> createState() => _ConsumerHomeScreenState();
}

class _ConsumerHomeScreenState extends State<ConsumerHomeScreen> {
  final _idController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _verifyManualId() async {
    final id = _idController.text.trim();
    if (id.isEmpty) return;
    setState(() => _isVerifying = true);
    final batch = await context.read<AppState>().verifyProduct(id);
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (batch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No batch found with that ID.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VerifyResultScreen(batch: batch)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: Colors.white, size: 30),
              SizedBox(height: 14),
              Text(
                'Verify a product\'s journey',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                'Scan the QR code on the packaging to see its full, '
                'cryptographically verifiable history — from raw material '
                'to the shelf.',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ScanScreen()),
            ),
            icon: Icon(Icons.qr_code_scanner, size: 20),
            label: Text('Scan QR Code'),
          ),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('or enter a batch ID', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 16),
        TextField(
          controller: _idController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. TC-BATCH-A1F00291',
            prefixIcon: Icon(Icons.tag_outlined),
          ),
          onSubmitted: (_) => _verifyManualId(),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isVerifying ? null : _verifyManualId,
            icon: _isVerifying
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.search, size: 18),
            label: Text(_isVerifying ? 'Checking ledger…' : 'Verify'),
          ),
        ),
      ],
    );
  }
}
