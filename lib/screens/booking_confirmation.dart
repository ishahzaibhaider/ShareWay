import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ride.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = ModalRoute.of(context)?.settings.arguments as Ride?
        ?? Ride.getMockRides().first;
    final bookingId = 'SW-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: const SwBackButton(),
        ),
        title: Text('Booking Confirmed', style: AppTheme.titleL),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Icon
            Sw3DIcon(icon: Icons.check_circle_rounded, baseColor: AppTheme.success, size: 48),
            const SizedBox(height: 24),
            Text("You're All Set!", style: AppTheme.displayXL),
            const SizedBox(height: 8),
            Text(
              'Your ride with ${ride.driverName} has been confirmed.',
              style: AppTheme.body.copyWith(color: AppTheme.textSub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Booking Card
            Sw3DCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  // Card Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: AppTheme.gradient3D([AppTheme.brandGreen, AppTheme.brandGreenLt]),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BOOKING ID: #$bookingId',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  color: Colors.white60,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                ride.destination,
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Sw3DIcon(icon: Icons.directions_car_rounded, baseColor: Colors.white24, size: 28),
                      ],
                    ),
                  ),

                  // Card Details
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _BookingRow('Driver', '${ride.driverName} ★${ride.rating}'),
                        _BookingRow('Vehicle', '${ride.carModel} · ${ride.carPlate}'),
                        _BookingRow('Pickup', '${ride.pickup} · ${ride.departureTime}'),
                        _BookingRow('Drop-off', '${ride.destination} · ${ride.arrivalTime}'),
                        _BookingRow(
                          'Fare',
                          'Rs ${ride.price.toInt()} (split)',
                          valueColor: AppTheme.brandGreen,
                        ),
                        _BookingRow('Payment', 'ShareWay Wallet'),
                        _BookingRow(
                          'Status',
                          '✓ Confirmed',
                          isLast: true,
                          valueColor: AppTheme.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Message Driver'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share Trip Details'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppTheme.border),
                foregroundColor: AppTheme.textSub,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
              child: Text(
                'Back to Home',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppTheme.textSub,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;
  const _BookingRow(this.label, this.value, {this.valueColor, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Text(label, style: AppTheme.caption),
          const Spacer(),
          Text(
            value,
            style: AppTheme.titleM.copyWith(
              color: valueColor ?? AppTheme.textMain,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
