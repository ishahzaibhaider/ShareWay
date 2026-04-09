import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class _Transaction {
  final String icon;
  final String name;
  final String subtitle;
  final double amount;
  final bool isCredit;
  const _Transaction({
    required this.icon, required this.name, required this.subtitle,
    required this.amount, required this.isCredit,
  });
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  static const List<_Transaction> _transactions = [
    _Transaction(icon: '🚗', name: 'Ride to COMSATS', subtitle: 'Today · 7:30 AM · Split fare', amount: 250, isCredit: false),
    _Transaction(icon: '💰', name: 'Wallet Top-up', subtitle: 'Apr 7 · Via Easypaisa', amount: 2000, isCredit: true),
    _Transaction(icon: '🚗', name: 'Ride to F-7 Markaz', subtitle: 'Apr 6 · Split with 2', amount: 180, isCredit: false),
    _Transaction(icon: '⭐', name: 'Referral Bonus', subtitle: 'Apr 5 · Nimra joined via your code', amount: 100, isCredit: true),
    _Transaction(icon: '🚗', name: 'Ride to PWD', subtitle: 'Apr 4 · 3 passengers', amount: 150, isCredit: false),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final balance = user?.balance ?? 0.0;
    final formatter = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppTheme.brandEspresso,
      body: Column(
        children: [
          // ── Dark Header ────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SwBackButton(
                        background: Color(0x22FFFFFF),
                        iconColor: Colors.white,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'My Wallet',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'TOTAL BALANCE',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rs ${formatter.format(balance)}',
                    style: GoogleFonts.outfit(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'Last updated: Today, ${DateFormat('h:mm a').format(DateTime.now())}',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _WalletActionBtn(label: '⬆️ Add Money', onTap: () {}),
                      const SizedBox(width: 10),
                      _WalletActionBtn(label: '⬇️ Withdraw', onTap: () {}),
                      const SizedBox(width: 10),
                      _WalletActionBtn(label: '↔️ Transfer', onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── White Panel ────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Payment Card
                    Text('Payment Card', style: AppTheme.titleL),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.brandGreen, AppTheme.brandGreenLt],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.contactless_rounded, color: Colors.white70, size: 28),
                              Text(
                                'PREMIUM',
                                style: GoogleFonts.outfit(
                                  fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white54,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '•••• •••• •••• 4242',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CARD HOLDER',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: Colors.white54,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    user?.name ?? 'Guest User',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'EXPIRES',
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: Colors.white54,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    '08/29',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Transactions
                    SwSectionHeader('Recent Transactions', action: 'See all'),
                    const SizedBox(height: 14),
                    ..._transactions.map(_buildTxnItem),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTxnItem(_Transaction txn) {
    IconData getIcon(String emoji) {
      switch (emoji) {
        case '🚗': return Icons.directions_car_rounded;
        case '💰': return Icons.account_balance_wallet_rounded;
        case '⭐': return Icons.stars_rounded;
        default:  return Icons.payment_rounded;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Sw3DCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Sw3DIcon(
              icon: getIcon(txn.icon),
              baseColor: txn.isCredit ? AppTheme.brandGreen : AppTheme.brandEspresso,
              size: 18,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(txn.name, style: AppTheme.titleM),
                  const SizedBox(height: 2),
                  Text(txn.subtitle, style: AppTheme.caption),
                ],
              ),
            ),
            Text(
              '${txn.isCredit ? '+' : '-'} Rs ${txn.amount.toInt()}',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: txn.isCredit ? AppTheme.success : AppTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _WalletActionBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
