import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/role_card.dart';
import 'architecture_screen.dart';
import 'home_shell.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 56 : 22,
                vertical: wide ? 36 : 22,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopMark(),
                    const SizedBox(height: 58),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRACECHAIN / ACCESS',
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enter the ledger.',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -1.4,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose the operating view for this session. Every role gets a different slice of the supply-chain record.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (wide)
                          IconButton(
                            tooltip: 'View network architecture',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => ArchitectureScreen()),
                            ),
                            icon: const Icon(Icons.account_tree_outlined),
                          ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    GridView.builder(
                      itemCount: UserRole.values.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: wide ? 3 : 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: wide ? 1.38 : .96,
                      ),
                      itemBuilder: (_, i) {
                        final role = UserRole.values[i];
                        return RoleCard(
                          role: role,
                          onTap: () => _handleRoleTap(context, role),
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 7),
                        Text(
                          'Demo identity layer  •  Ledger data is local mock data',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Toggle appearance',
                          onPressed: context.read<AppState>().toggleTheme,
                          icon: Icon(
                            context.watch<AppState>().isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleRoleTap(BuildContext context, UserRole role) async {
    if (role == UserRole.consumer) {
      _proceed(context, role, 'Guest Consumer');
      return;
    }

    final controller = TextEditingController();
    final name = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(role.icon, color: role.color),
                const SizedBox(width: 10),
                Text('Open ${role.label} workspace', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Use an organization or display name for this demo session.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Organization / display name',
                hintText: 'e.g. Harvest Mills Pvt. Ltd.',
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (v) => Navigator.of(context).pop(v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(controller.text),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text('Open workspace'),
              ),
            ),
          ],
        ),
      ),
    );

    if (name == null || !context.mounted) return;
    _proceed(context, role, name);
  }

  void _proceed(BuildContext context, UserRole role, String name) {
    context.read<AppState>().selectRole(role, name);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HomeShell()));
  }
}

class _TopMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 11),
        Text(
          'tracechain',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Network architecture',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ArchitectureScreen()),
          ),
          icon: const Icon(Icons.account_tree_outlined),
        ),
      ],
    );
  }
}
