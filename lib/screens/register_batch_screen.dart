import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'batch_detail_screen.dart';

class RegisterBatchScreen extends StatefulWidget {
  RegisterBatchScreen({super.key});

  @override
  State<RegisterBatchScreen> createState() => _RegisterBatchScreenState();
}

class _RegisterBatchScreenState extends State<RegisterBatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _originController = TextEditingController();
  final _materialController = TextEditingController();
  String _category = 'Grains & Cereals';
  final List<String> _materials = [];
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Grains & Cereals',
    'Edible Oils',
    'Dairy',
    'Seafood',
    'Fruits & Vegetables',
    'Beverages',
  ];

  @override
  void dispose() {
    _productController.dispose();
    _originController.dispose();
    _materialController.dispose();
    super.dispose();
  }

  void _addMaterial() {
    final text = _materialController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _materials.add(text);
      _materialController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_materials.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least one raw material input.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final batch = await context.read<AppState>().registerBatch(
            productName: _productController.text.trim(),
            category: _category,
            rawMaterials: _materials,
            originLocation: _originController.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: batch)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register New Batch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This calls registerBatch() — a new batch ID and '
                      'registration transaction hash are generated as if by '
                      'the chaincode.',
                      style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _Label('Product name'),
            TextFormField(
              controller: _productController,
              decoration: InputDecoration(hintText: 'e.g. Organic Basmati Rice — 25kg sacks'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 18),
            _Label('Category'),
            DropdownButtonFormField<String>(
              value: _category,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            SizedBox(height: 18),
            _Label('Origin location'),
            TextFormField(
              controller: _originController,
              decoration: InputDecoration(hintText: 'e.g. Thanjavur, TN'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            SizedBox(height: 18),
            _Label('Raw material inputs'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _materialController,
                    decoration: InputDecoration(hintText: 'e.g. Paddy (Farm Cluster 4)'),
                    onFieldSubmitted: (_) => _addMaterial(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addMaterial,
                  icon: Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
            if (_materials.isNotEmpty) ...[
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _materials
                    .map((m) => Chip(
                          label: Text(m, style: TextStyle(fontSize: 12)),
                          onDeleted: () => setState(() => _materials.remove(m)),
                        ))
                    .toList(),
              ),
            ],
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(Icons.add_circle_outline, size: 18),
                label: Text(_isSubmitting ? 'Submitting to ledger…' : 'Register Batch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.inkMuted),
      ),
    );
  }
}
