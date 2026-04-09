import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context, user),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatsStrip(user),
                  _buildMenuSection(context, auth, user),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SwUser? user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.brandGreen, AppTheme.brandGreenLt],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          child: Column(
            children: [
              Row(
                children: [
                  const SwBackButton(
                    background: Color(0x22FFFFFF),
                    iconColor: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Your Account',
                    style: GoogleFonts.outfit(
                      fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.accent, shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Guest User',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'Not logged in',
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60),
              ),
              const SizedBox(height: 10),
              if (user?.isVerified ?? false)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 14, color: AppTheme.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Verified Student',
                        style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsStrip(SwUser? user) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            _StatCol('${user?.totalRides ?? 0}', 'Rides'),
            _VertDivider(),
            _StatCol('${user?.rating ?? 5.0}', 'Rating'),
            _VertDivider(),
            _StatCol('Rs 0', 'Saved'),
            _VertDivider(),
            _StatCol('0 kg', 'CO₂ ↓'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, AuthService auth, SwUser? user) {
    IconData getIcon(String emoji) {
      switch (emoji) {
        case '👤': return Icons.person_rounded;
        case '🚗': return Icons.directions_car_rounded;
        case '📋': return Icons.history_rounded;
        case '🔔': return Icons.notifications_rounded;
        case '🛡️': return Icons.security_rounded;
        case '💳': return Icons.account_balance_wallet_rounded;
        case '🎁': return Icons.card_giftcard_rounded;
        case '❓': return Icons.help_outline_rounded;
        default:  return Icons.menu_rounded;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MenuLabel('Account'),
          _MenuItem(icon: getIcon('👤'), bg: const Color(0xFFE8F4EA), title: 'Edit Profile', subtitle: 'Update your info & photo'),
          _MenuItem(
            icon: getIcon('🚗'), 
            bg: const Color(0xFFFEF0E6), 
            title: 'My Vehicle', 
            subtitle: user?.carModel != null ? '${user!.carModel} · ${user.carPlate}' : 'Tesla Model 3 · ABC-1234',
          ),
          _MenuItem(icon: getIcon('📋'), bg: const Color(0xFFFEF9E7), title: 'Trip History', subtitle: '${user?.totalRides ?? 47} completed rides'),
          const SizedBox(height: 20),
          _MenuLabel('Preferences'),
          _MenuItem(icon: getIcon('🔔'), bg: const Color(0xFFEAF3DE), title: 'Notifications', subtitle: 'Ride alerts & updates'),
          _MenuItem(icon: getIcon('🛡️'), bg: const Color(0xFFF0ECFE), title: 'Privacy & Safety', subtitle: 'Location & data sharing'),
          _MenuItem(icon: getIcon('💳'), bg: const Color(0xFFE6F1FB), title: 'Payment Methods', subtitle: 'Cards & wallet'),
          const SizedBox(height: 20),
          _MenuLabel('More'),
          _MenuItem(icon: getIcon('🎁'), bg: const Color(0xFFFEF0E6), title: 'Refer & Earn', subtitle: 'Get Rs 100 per referral'),
          _MenuItem(icon: getIcon('❓'), bg: const Color(0xFFEAF3DE), title: 'Help & Support', subtitle: 'FAQs and contact'),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFCCCC)),
                boxShadow: [
                  BoxShadow(color: AppTheme.danger.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, color: AppTheme.danger, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: GoogleFonts.outfit(
                      fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.danger,
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

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  const _StatCol(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textMain)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, color: AppTheme.textSub)),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: AppTheme.border);
}

class _MenuLabel extends StatelessWidget {
  final String label;
  const _MenuLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: AppTheme.textSub, letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final String title;
  final String subtitle;
  const _MenuItem({required this.icon, required this.bg, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Sw3DCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Sw3DIcon(icon: icon, baseColor: bg, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.titleM),
                  Text(subtitle, style: AppTheme.caption),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppTheme.border),
          ],
        ),
      ),
    );
  }
}
