import 'dart:ui' show ImageFilter;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

/// Glass top bar used across tabs. `leading` defaults to a menu icon that
/// navigates back when `onLeadingTap` is provided.
class BlurredAppBar extends StatelessWidget {
  const BlurredAppBar({
    super.key,
    required this.title,
    this.onLeadingTap,
    this.leadingIcon,
    this.trailing,
  });

  final String title;
  final VoidCallback? onLeadingTap;
  final IconData? leadingIcon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final user = FirebaseAuth.instance.currentUser;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(24, top + 8, 24, 12),
          color: AppColors.surface.withValues(alpha: 0.82),
          child: Row(
            children: [
              IconButton(
                onPressed: onLeadingTap ?? () {},
                icon: Icon(
                  leadingIcon ?? Icons.menu_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.primary,
                  ),
                ),
              ),
              trailing ?? _HeaderAvatar(user: user),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final url = user?.photoURL;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _AvatarFallback(),
            )
          : const _AvatarFallback(),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceContainerHigh,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}
