import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/batch.dart';
import '../models/user_role.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'batch_detail_screen.dart';

class TransferCustodyScreen extends StatefulWidget {
  TransferCustodyScreen({
    super.key,
    required this.batch,
  });

  final Batch batch;

  @override
  State<TransferCustodyScreen> createState() =>
      _TransferCustodyScreenState();
}

class _TransferCustodyScreenState
    extends State<TransferCustodyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toEntityController = TextEditingController();
  final _locationController = TextEditingController();

  late UserRole _toRole;

  bool _conditionsOk = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _toRole = _receivableRoleFor(widget.batch.currentHolderRole);
  }

  UserRole _receivableRoleFor(UserRole? currentRole) {
    switch (currentRole) {
      case UserRole.manufacturer:
        return UserRole.distributor;

      case UserRole.distributor:
        return UserRole.retailer;

      default:
        return UserRole.distributor;
    }
  }

  List<UserRole> _receivableRoles(UserRole? currentRole) {
    switch (currentRole) {
      case UserRole.manufacturer:
        return const [
          UserRole.distributor,
        ];

      case UserRole.distributor:
        return const [
          UserRole.retailer,
        ];

      default:
        return const [];
    }
  }

  @override
  void dispose() {
    _toEntityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final updated =
          await context.read<AppState>().transferCustody(
                batchId: widget.batch.id,
                toEntity: _toEntityController.text.trim(),
                toRole: _toRole,
                location: _locationController.text.trim(),
                conditionsOk: _conditionsOk,
              );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BatchDetailScreen(
            batch: updated,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Bad state: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivingRoles =
        _receivableRoles(widget.batch.currentHolderRole);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Custody'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.batch.id} · ${widget.batch.productName}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const _Label('Transferring from'),

            TextFormField(
              enabled: false,
              initialValue: widget.batch.currentHolderName,
            ),

            const SizedBox(height: 18),

            const _Label('Receiving role'),

            Wrap(
              spacing: 10,
              children: receivingRoles.map((role) {
                final selected = _toRole == role;

                return ChoiceChip(
                  label: Text(role.label),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _toRole = role;
                    });
                  },
                  selectedColor:
                      AppColors.primary.withOpacity(0.14),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            const _Label('Receiving entity name'),

            TextFormField(
              controller: _toEntityController,
              decoration: const InputDecoration(
                hintText: 'e.g. Kerala Distribution Hub',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            const _Label('Handoff location'),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Chennai Distribution Hub',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),

            const SizedBox(height: 18),

            const _Label('Condition check'),

            Card(
              child: SwitchListTile(
                value: _conditionsOk,
                onChanged: (v) {
                  setState(() {
                    _conditionsOk = v;
                  });
                },
                title: const Text(
                  'Conditions within agreed range',
                  style: TextStyle(
                    fontSize: 13.5,
                  ),
                ),
                subtitle: Text(
                  'Turn off to flag a temperature/humidity breach on this handoff',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.inkMuted,
                  ),
                ),
                activeColor: AppColors.success,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.sync_alt,
                        size: 18,
                      ),
                label: Text(
                  _isSubmitting
                      ? 'Recording on ledger…'
                      : 'Confirm Transfer',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.inkMuted,
        ),
      ),
    );
  }
}