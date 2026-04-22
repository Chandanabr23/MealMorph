import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/strings/app_strings.dart';
import '../../../../core/strings/app_strings_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/widgets/blurred_app_bar.dart';
import '../../../shell/presentation/widgets/main_bottom_nav.dart';
import '../../data/profile_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onNavigateTab});

  final ValueChanged<MainTab>? onNavigateTab;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfilePreferences? _prefs;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ProfilePreferences.load()
        .then((p) {
          if (!mounted) return;
          setState(() => _prefs = p);
        })
        .catchError((_) {
          // If the native shared_preferences channel isn't registered yet
          // (stale build after adding the plugin), fall through to defaults.
        });
  }

  Future<void> _logout() async {
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDelete() async {
    final s = AppStringsScope.of(context).profile;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          s.confirmDeleteTitle,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          s.confirmDeleteBody,
          style: GoogleFonts.beVietnamPro(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.confirmDeleteCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.confirmDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final s = AppStringsScope.of(context).profile;
    setState(() => _busy = true);
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.deleteAccountSuccess)));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'requires-recent-login'
          ? s.deleteRequiresRecentLogin
          : (e.message?.trim().isNotEmpty == true
                ? e.message!
                : 'Failed to delete account.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _select(MainTab tab) => widget.onNavigateTab?.call(tab);

  @override
  Widget build(BuildContext context) {
    final s = AppStringsScope.of(context).profile;
    final appTitle = AppStringsScope.of(context).app.title;
    final user = FirebaseAuth.instance.currentUser;
    final display = _displayName(user, s.defaultName);
    final joined = user?.metadata.creationTime?.year ?? DateTime.now().year;
    final role = s.roleLabel.replaceAll('{year}', '$joined');
    final bottomInset = MediaQuery.paddingOf(context).bottom + 120;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(height: MediaQuery.paddingOf(context).top + 72),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    s.pageTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ProfileHero(
                    user: user,
                    name: display,
                    role: role,
                  ),
                  const SizedBox(height: 32),
                  _AccountDetailsCard(strings: s),
                  const SizedBox(height: 24),
                  _CookingSkillCard(
                    strings: s,
                    skill: _prefs?.cookingSkill ?? CookingSkill.intermediate,
                    onChanged: (skill) async {
                      await _prefs?.setCookingSkill(skill);
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 24),
                  _NotificationsCard(
                    strings: s,
                    enabled: _prefs?.notificationsEnabled ?? true,
                    onChanged: (v) async {
                      await _prefs?.setNotificationsEnabled(v);
                      if (!mounted) return;
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 40),
                  _LogoutButton(label: s.logoutCta, onPressed: _busy ? null : _logout),
                  const SizedBox(height: 16),
                  _DeleteAccountButton(
                    label: s.deleteAccountCta,
                    onPressed: _busy ? null : _confirmDelete,
                  ),
                ]),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlurredAppBar(
            title: appTitle,
            leadingIcon: Icons.close_rounded,
            onLeadingTap: () => _select(MainTab.home),
          ),
        ),
      ],
    );
  }
}

String _displayName(User? user, String fallback) {
  final raw = user?.displayName?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty) {
    final at = email.indexOf('@');
    final base = at > 0 ? email.substring(0, at) : email;
    if (base.isNotEmpty) {
      return '${base[0].toUpperCase()}${base.substring(1)}';
    }
  }
  return fallback;
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.name, required this.role});

  final User? user;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final photo = user?.photoURL;
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 4,
            ),
            boxShadow: [AppColors.editorialShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: photo != null && photo.isNotEmpty
              ? Image.network(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _HeroAvatarFallback(),
                )
              : const _HeroAvatarFallback(),
        ),
        const SizedBox(height: 20),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          role,
          style: GoogleFonts.beVietnamPro(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HeroAvatarFallback extends StatelessWidget {
  const _HeroAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainerHigh,
      child: const Icon(
        Icons.person_rounded,
        size: 64,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  const _AccountDetailsCard({required this.strings});

  final ProfileScreenStrings strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.accountDetailsTitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.accountDetailsSubtitle,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _CookingSkillCard extends StatelessWidget {
  const _CookingSkillCard({
    required this.strings,
    required this.skill,
    required this.onChanged,
  });

  final ProfileScreenStrings strings;
  final CookingSkill skill;
  final ValueChanged<CookingSkill> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                strings.cookingSkillTitle,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _SkillChip(
                label: strings.cookingSkillNovice,
                selected: skill == CookingSkill.novice,
                onTap: () => onChanged(CookingSkill.novice),
              ),
              const SizedBox(width: 8),
              _SkillChip(
                label: strings.cookingSkillIntermediate,
                selected: skill == CookingSkill.intermediate,
                onTap: () => onChanged(CookingSkill.intermediate),
              ),
              const SizedBox(width: 8),
              _SkillChip(
                label: strings.cookingSkillMaster,
                selected: skill == CookingSkill.master,
                onTap: () => onChanged(CookingSkill.master),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: selected
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({
    required this.strings,
    required this.enabled,
    required this.onChanged,
  });

  final ProfileScreenStrings strings;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              strings.notificationsTitle,
              style: GoogleFonts.beVietnamPro(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.onSurface, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: errorColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
