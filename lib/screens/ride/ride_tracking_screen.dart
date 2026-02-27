import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideTrackingScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  Future<void> _completeRide() async {
    try {
      await ref
          .read(firestoreServiceProvider)
          .updateRide(widget.rideId, {'status': 'completed'});
      if (mounted) {
        context.go('/rate/${widget.rideId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openInGoogleMaps({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Tracking'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: rideAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ride) {
          if (ride == null) {
            return const Center(child: Text('Ride not found'));
          }

          final isDriver = currentUser?.uid == ride.driverId;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Ride status card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          ride.status == 'started'
                              ? Icons.directions_car
                              : Icons.check_circle,
                          size: 64,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ride.status == 'started'
                              ? 'Ride in Progress'
                              : 'Ride ${ride.status}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${ride.passengers.where((p) => p.status == 'accepted').length} passenger(s)',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Route info card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 14),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ride.origin.address,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.more_vert, size: 18, color: Colors.grey),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ride.destination.address,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Distance & fare
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.straighten, color: AppTheme.primaryColor),
                              const SizedBox(height: 8),
                              Text(
                                '${ride.estimatedDistance.toStringAsFixed(1)} km',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('Distance', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.attach_money, color: AppTheme.primaryColor),
                              const SizedBox(height: 8),
                              Text(
                                'Rs. ${ride.estimatedFare.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('Fare', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Open in Google Maps button
                CustomButton(
                  text: 'Navigate in Google Maps',
                  icon: Icons.navigation,
                  onPressed: () => _openInGoogleMaps(
                    originLat: ride.origin.lat,
                    originLng: ride.origin.lng,
                    destLat: ride.destination.lat,
                    destLng: ride.destination.lng,
                  ),
                ),
                const SizedBox(height: 12),

                if (isDriver && ride.status == 'started')
                  CustomButton(
                    text: 'Complete Ride',
                    icon: Icons.check_circle,
                    onPressed: _completeRide,
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
