import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class RideDetailsScreen extends StatefulWidget {
  const RideDetailsScreen({super.key});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  // Set to false to see the real map (requires API Key)
  final bool _useMockMap = true;

  @override
  Widget build(BuildContext context) {
    final ride = ModalRoute.of(context)?.settings.arguments as Ride?
        ?? Ride.getMockRides().first;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Map Area ────────────────────────────────────────────────────
          _buildMapArea(context, ride),
          // ── Bottom Sheet ────────────────────────────────────────────────
          Expanded(child: _buildDetailSheet(context, ride)),
        ],
      ),
    );
  }

  Widget _buildMapArea(BuildContext context, Ride ride) {
    final pickup = LatLng(ride.pickupLat, ride.pickupLng);
    final destination = LatLng(ride.destLat, ride.destLng);

    return Stack(
      children: [
        Container(
          height: 270,
          width: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFFD4E8D6)),
          child: _useMockMap
              ? CustomPaint(painter: _MapPainter())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(target: pickup, zoom: 12),
                  markers: {
                    Marker(markerId: const MarkerId('p'), position: pickup, infoWindow: InfoWindow(title: ride.pickup)),
                    Marker(markerId: const MarkerId('d'), position: destination, infoWindow: InfoWindow(title: ride.destination)),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                ),
        ),
        // Overlay gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppTheme.background.withOpacity(0.8)],
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 16,
          child: const SwBackButton(),
        ),
        // Route pill
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 8, color: AppTheme.brandGreen),
                  const SizedBox(width: 6),
                  Text(
                    '${ride.pickup}  →  ${ride.destination}',
                    style: AppTheme.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.location_on, size: 8, color: Colors.red),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSheet(BuildContext context, Ride ride) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Driver Row ───────────────────────────────────────────────
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.sand,
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.verified_rounded, size: 16, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driverName, style: AppTheme.displayM.copyWith(fontSize: 20)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${ride.carModel} · ${ride.carPlate}',
                            style: AppTheme.caption,
                          ),
                          const SizedBox(width: 8),
                          SwStarRating(ride.rating),
                        ],
                      ),
                    ],
                  ),
                ),
                Sw3DIcon(icon: Icons.chat_bubble_outline_rounded, baseColor: AppTheme.brandGreen, size: 20),
              ],
            ),
            const SizedBox(height: 24),

            // ── Route Display ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.sandDecoration,
              child: Column(
                children: [
                  _RoutePoint(
                    icon: Icons.circle,
                    iconColor: AppTheme.brandGreen,
                    label: ride.pickup,
                    sub: 'Pickup · ${ride.departureTime}',
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Column(
                      children: List.generate(
                        3,
                        (_) => Container(
                          width: 2,
                          height: 6,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: AppTheme.border,
                        ),
                      ),
                    ),
                  ),
                  _RoutePoint(
                    icon: Icons.location_on_rounded,
                    iconColor: Colors.red,
                    label: ride.destination,
                    sub: 'Drop-off · ${ride.arrivalTime}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Stats Row ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: SwStatBox(
                    icon: Icons.access_time_rounded,
                    value: ride.duration,
                    label: 'Duration',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwStatBox(
                    icon: Icons.airline_seat_recline_extra_rounded,
                    value: '${ride.availableSeats} left',
                    label: 'Seats',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SwStatBox(
                    icon: Icons.straighten_rounded,
                    value: '${ride.distanceKm} km',
                    label: 'Distance',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Price Banner ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.brandGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fare per seat',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rs ${ride.price.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Split with other riders',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'You save',
                        style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.white60,
                        ),
                      ),
                      Text(
                        'Rs ${ride.savingsEstimate.toInt()}',
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Action Row ───────────────────────────────────────────────
            Row(
              children: [
                _IconActionBtn(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => Navigator.pushNamed(context, '/chat'),
                ),
                const SizedBox(width: 10),
                _IconActionBtn(
                  icon: Icons.phone_outlined,
                  onTap: () {},
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/booking', arguments: ride),
                    child: const Text('Confirm Ride'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  const _RoutePoint({
    required this.icon, required this.iconColor,
    required this.label, required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.titleM),
            Text(sub, style: AppTheme.caption),
          ],
        ),
      ],
    );
  }
}

class _IconActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppTheme.sand,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 20, color: AppTheme.textMain),
      ),
    );
  }
}

// Simple painted map placeholder
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final routePaint = Paint()
      ..color = AppTheme.brandGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Roads
    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.65), roadPaint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(size.width * 0.65, 0), Offset(size.width * 0.65, size.height), roadPaint);

    // Route
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.25)
      ..lineTo(size.width * 0.3, size.height * 0.4)
      ..lineTo(size.width * 0.65, size.height * 0.4)
      ..lineTo(size.width * 0.65, size.height * 0.65);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.brandGreen
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
