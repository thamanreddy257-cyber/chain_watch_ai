import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class NavDestinationItem {
  final String label;
  final IconData icon;
  final String path;

  const NavDestinationItem(
      {required this.label, required this.icon, required this.path});
}

const List<NavDestinationItem> kNavDestinations = [
  NavDestinationItem(
      label: 'Dashboard', icon: LucideIcons.layoutDashboard, path: '/dashboard'),
  NavDestinationItem(
      label: 'Investigate', icon: LucideIcons.search, path: '/wallet'),
  NavDestinationItem(
      label: 'Network', icon: LucideIcons.share2, path: '/network'),
  NavDestinationItem(
      label: 'Alerts', icon: LucideIcons.shieldAlert, path: '/alerts'),
  NavDestinationItem(
      label: 'AI Assistant', icon: LucideIcons.bot, path: '/assistant'),
  NavDestinationItem(
      label: 'Reports', icon: LucideIcons.fileText, path: '/reports'),
];

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentPath;
  final ValueChanged<String> onNavigate;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
    required this.onNavigate,
  });

  int get _currentIndex {
    final i = kNavDestinations.indexWhere((d) => currentPath.startsWith(d.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            _Sidebar(
              currentIndex: _currentIndex,
              onSelect: (d) => onNavigate(d.path),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.shield, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('CHAINWATCH AI', style: AppTextStyles.headlineSmall.copyWith(fontSize: 15)),
          ],
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: kNavDestinations.map((d) {
                final selected = kNavDestinations.indexOf(d) == _currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onNavigate(d.path),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(d.icon,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted),
                        const SizedBox(height: 4),
                        Text(
                          d.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<NavDestinationItem> onSelect;

  const _Sidebar({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(LucideIcons.shield,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'CHAINWATCH',
                    style: AppTextStyles.headlineSmall.copyWith(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('MENU', style: AppTextStyles.label),
          ),
          const SizedBox(height: 8),
          ...kNavDestinations.asMap().entries.map((entry) {
            final selected = entry.key == currentIndex;
            final d = entry.value;
            return _SidebarItem(
              item: d,
              selected: selected,
              onTap: () => onSelect(d),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                        color: AppColors.secondary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'System Online',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
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
}

class _SidebarItem extends StatefulWidget {
  final NavDestinationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem(
      {required this.item, required this.selected, required this.onTap});

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : (_hovering
                      ? AppColors.borderSubtle
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon,
                    size: 18,
                    color: active ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  widget.item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: active ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
