import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_role.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/network_status_pill.dart';
import 'architecture_screen.dart';
import 'consumer_home_screen.dart';
import 'handler_dashboard.dart';
import 'manufacturer_dashboard.dart';
import 'regulator_dashboard.dart';
import 'register_batch_screen.dart';
import 'role_select_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final role = state.currentRole;

    if (role == null) return const RoleSelectScreen();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;

          return Row(
            children: [
              if (wide) _SideRail(role: role),
              Expanded(
                child: Column(
                  children: [
                    _CommandHeader(role: role),
                    Expanded(child: _bodyForRole(role)),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // Mobile: floating New Batch button
      floatingActionButton:
          !wideEnough(context) && role == UserRole.manufacturer
              ? FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RegisterBatchScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New batch'),
                )
              : null,
    );
  }

  bool wideEnough(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 820;
  }

  Widget _bodyForRole(UserRole role) {
    switch (role) {
      case UserRole.manufacturer:
        return ManufacturerDashboard();

      case UserRole.distributor:
        return HandlerDashboard(
          role: UserRole.distributor,
        );

      case UserRole.retailer:
        return HandlerDashboard(
          role: UserRole.retailer,
        );

      case UserRole.regulator:
        return RegulatorDashboard();

      case UserRole.consumer:
        return ConsumerHomeScreen();
    }
  }
}

class _CommandHeader extends StatelessWidget {
  const _CommandHeader({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final dark = state.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 18, 14),
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width < 820)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: role.color.withOpacity(.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                role.icon,
                size: 19,
                color: role.color,
              ),
            ),

          if (MediaQuery.sizeOf(context).width < 820)
            const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _workspaceTitle(role),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.currentUserName}  ·  ${role.label}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // REGISTER BATCH BUTTON
          if (role == UserRole.manufacturer) ...[
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegisterBatchScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_rounded,
                size: 18,
              ),
              label: const Text('Register batch'),
            ),
            const SizedBox(width: 10),
          ],

          const NetworkStatusPill(),

          const SizedBox(width: 6),

          Tooltip(
            message:
                dark ? 'Switch to light mode' : 'Switch to dark mode',
            child: IconButton(
              onPressed: state.toggleTheme,
              icon: AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: Icon(
                  dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  key: ValueKey(dark),
                  size: 20,
                ),
              ),
            ),
          ),

          IconButton(
            tooltip: 'System architecture',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ArchitectureScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_tree_outlined,
              size: 20,
            ),
          ),

          IconButton(
            tooltip: 'Switch role',
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _workspaceTitle(UserRole role) {
    switch (role) {
      case UserRole.manufacturer:
        return 'Production ledger';

      case UserRole.distributor:
        return 'Custody desk';

      case UserRole.retailer:
        return 'Store inventory';

      case UserRole.regulator:
        return 'Oversight console';

      case UserRole.consumer:
        return 'Product verification';
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Switch workspace?'),
          content: const Text(
            'You will return to the role selection screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<AppState>().signOut();

                Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                );
              },
              child: const Text('Switch'),
            ),
          ],
        );
      },
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<AppState>();

    return Container(
      width: 86,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          right: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.hub_rounded,
              color: scheme.primary,
              size: 24,
            ),
          ),

          const SizedBox(height: 34),

          _RailItem(
            icon: role.icon,
            label: 'Workspace',
            selected: true,
          ),

          _RailItem(
            icon: Icons.account_tree_outlined,
            label: 'Network',
          ),

          const Spacer(),

          Tooltip(
            message:
                state.isDarkMode ? 'Light mode' : 'Dark mode',
            child: IconButton.filledTonal(
              onPressed: state.toggleTheme,
              icon: Icon(
                state.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          ),

          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 38,
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withOpacity(.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: selected
                  ? scheme.primary
                  : scheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}