import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/database_service.dart';
import '../models/models.dart';

// ─── Responsive Helper ──────────────────────────────────────────────────────
class Responsive {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Scale based on a standard mobile width of 375
  // Clamped to avoid extreme scaling on very large or very small screens
  static double scale(BuildContext context) {
    double w = screenWidth(context);
    if (w > 1200) return 1.6; // Large Desktop
    if (w > 900) return 1.4; // Desktop
    if (w > 600) return 1.2; // Tablet
    return (w / 375).clamp(0.9, 1.1); // Mobile
  }

  // Fluid Font Size
  static double sp(BuildContext context, double size) => size * scale(context);

  // Relative Width/Height
  static double w(BuildContext context, double percentage) =>
      screenWidth(context) * (percentage / 100);
  static double h(BuildContext context, double percentage) =>
      screenHeight(context) * (percentage / 100);
}

// ─── Gradient Background Scaffold ──────────────────────────────────────────
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const GradientScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gradStart,
              AppColors.gradMid,
              AppColors.gradEnd,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

// ─── Frosted Glass Card ─────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

// ─── Stat Card ──────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Responsive.sp(context, 24),
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Responsive.sp(context, 12),
              fontWeight: FontWeight.w500,
              color: AppColors.textMid,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.sp(context, 10),
                color: AppColors.textLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Responsive.sp(context, 16),
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Avatar with gradient ────────────────────────────────────────────────────
class GradientAvatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const GradientAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────
class LabeledProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String? trailing;

  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w500,
                color: AppColors.textMid,
              ),
            ),
            Text(
              trailing ?? '${(value * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Responsive.sp(context, 13),
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// ─── Custom Bottom Nav ────────────────────────────────────────────────────────
class VidyaBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const VidyaBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.activeColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive ? activeColor : AppColors.textLight,
                        size: 22,
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 6),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: activeColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Greeting Header ──────────────────────────────────────────────────────────
class DashboardHeader extends StatelessWidget {
  final String name;
  final String role;
  final String? subtitle;
  final Color roleColor;
  final VoidCallback? onNotification;
  final int notificationCount;
  final bool showNotification;
  final List<Widget>? actionButtons;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.role,
    this.subtitle,
    required this.roleColor,
    this.onNotification,
    this.notificationCount = 0,
    this.showNotification = true,
    this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GradientAvatar(
          initials: name.substring(0, 2).toUpperCase(),
          color: roleColor,
          size: 50,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Responsive.sp(context, 12),
                    color: AppColors.textLight,
                  ),
                ),
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Responsive.sp(context, 18),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Responsive.sp(context, 10),
                    fontWeight: FontWeight.w600,
                    color: roleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (actionButtons != null) ...[
          const SizedBox(width: 8),
          ...actionButtons!,
        ],
        if (showNotification) ...[
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: onNotification,
                child: const GlassCard(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.notifications_outlined,
                      color: AppColors.textDark, size: 22),
                ),
              ),
              if (notificationCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Broadcast Notices Sheet ─────────────────────────────────────────────────
/// Shows notices sent by admin for a specific role
/// Usage: showBroadcastNoticesSheet(context, 'student')
void showBroadcastNoticesSheet(BuildContext context, String role) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _BroadcastNoticesSheet(role: role),
  );
}

class _BroadcastNoticesSheet extends StatefulWidget {
  final String role;
  const _BroadcastNoticesSheet({required this.role});

  @override
  State<_BroadcastNoticesSheet> createState() => _BroadcastNoticesSheetState();
}

class _BroadcastNoticesSheetState extends State<_BroadcastNoticesSheet> {
  final _db = DatabaseService();
  List<Broadcast> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    final notices = await _db.getBroadcastsForRole(widget.role);
    if (mounted) setState(() { _notices = notices; _loading = false; });
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high': return AppColors.warning;
      case 'urgent': return AppColors.error;
      default: return AppColors.info;
    }
  }

  IconData _priorityIcon(String p) {
    switch (p) {
      case 'high': return Icons.priority_high_rounded;
      case 'urgent': return Icons.warning_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    // Convert to local time for comparison
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.isNegative || diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${local.day}/${local.month}/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Text('Notices & Announcements',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const Spacer(),
                  if (_notices.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('${_notices.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.error)),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _notices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 56, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('No notices yet', style: TextStyle(fontSize: 15, color: Colors.grey[500])),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _notices.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final n = _notices[i];
                            final color = _priorityColor(n.priority);
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: color.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(_priorityIcon(n.priority), size: 18, color: color),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(n.title,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textDark)),
                                            const SizedBox(height: 2),
                                            Text(_timeAgo(n.sentDate),
                                                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(n.priority.toUpperCase(),
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(n.message,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textMid,
                                          height: 1.5)),
                                  const SizedBox(height: 8),
                                  Text('From: ${n.sentBy} • ${n.targetAudience}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
