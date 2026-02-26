import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/ride_model.dart';
import '../../models/ride_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class RideDetailsScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideDetailsScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends ConsumerState<RideDetailsScreen> {
  bool _isRequesting = false;

  Future<void> _sendRideRequest(RideModel ride) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isRequesting = true);
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final request = RideRequestModel(
        id: '',
        passengerId: user.uid,
        passengerName: user.name,
        passengerPhoto: user.profilePhoto,
        passengerRating: user.averageRating,
        rideId: widget.rideId,
        driverId: ride.driverId,
        pickupLocation: ride.origin,
        dropoffLocation: ride.destination,
      );
      await firestoreService.createRideRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride request sent!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Map Preview
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(ride.origin.lat, ride.origin.lng),
                      zoom: 12,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('origin'),
                        position: LatLng(ride.origin.lat, ride.origin.lng),
                        infoWindow:
                            InfoWindow(title: 'Pickup', snippet: ride.origin.address),
                      ),
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: LatLng(
                            ride.destination.lat, ride.destination.lng),
                        infoWindow: InfoWindow(
                            title: 'Dropoff', snippet: ride.destination.address),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Driver Info Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor:
                                    AppTheme.primaryColor.withOpacity(0.1),
                                child: Text(
                                  ride.driverName.isNotEmpty
                                      ? ride.driverName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ride.driverName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                            '${ride.driverRating.toStringAsFixed(1)} rating'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (!isDriver)
                                IconButton(
                                  onPressed: () async {
                                    final firestoreService =
                                        ref.read(firestoreServiceProvider);
                                    final chatId = await firestoreService
                                        .getOrCreateChatRoom(
                                      userId1: currentUser!.uid,
                                      userId2: ride.driverId,
                                      rideId: ride.id,
                                    );
                                    if (mounted) {
                                      context.push('/chat/$chatId');
                                    }
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline,
                                      color: AppTheme.primaryColor),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Route Details
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                Icons.circle_outlined,
                                AppTheme.primaryColor,
                                'From',
                                ride.origin.address,
                              ),
                              const Divider(),
                              _buildDetailRow(
                                Icons.location_on,
                                AppTheme.accentColor,
                                'To',
                                ride.destination.address,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ride Info Grid
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.calendar_today,
                                      'Date',
                                      DateFormat('MMM dd, yyyy')
                                          .format(ride.departureTime),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.access_time,
                                      'Time',
                                      DateFormat('hh:mm a')
                                          .format(ride.departureTime),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.event_seat,
                                      'Seats',
                                      '${ride.availableSeats} of ${ride.totalSeats}',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.attach_money,
                                      'Fare/Person',
                                      'Rs. ${ride.estimatedFare.toStringAsFixed(0)}',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.straighten,
                                      'Distance',
                                      '${ride.estimatedDistance.toStringAsFixed(1)} km',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoTile(
                                      Icons.repeat,
                                      'Type',
                                      ride.rideType == 'recurring'
                                          ? 'Recurring'
                                          : 'One-time',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Methods
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Methods',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children:
                                    ride.paymentMethods.map((method) {
                                  IconData icon;
                                  switch (method.toLowerCase()) {
                                    case 'easypaisa':
                                      icon = Icons.phone_android;
                                      break;
                                    case 'jazzcash':
                                      icon = Icons.phone_android;
                                      break;
                                    case 'bank transfer':
                                      icon = Icons.account_balance;
                                      break;
                                    default:
                                      icon = Icons.money;
                                  }
                                  return Chip(
                                    avatar: Icon(icon, size: 18),
                                    label: Text(method),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Button
                      if (!isDriver &&
                          ride.status == 'active' &&
                          ride.availableSeats > 0)
                        CustomButton(
                          text: 'Request Ride',
                          isLoading: _isRequesting,
                          icon: Icons.send,
                          onPressed: () => _sendRideRequest(ride),
                        ),

                      if (isDriver && ride.status == 'active')
                        CustomButton(
                          text: 'Start Ride',
                          icon: Icons.play_arrow,
                          onPressed: () async {
                            await ref
                                .read(firestoreServiceProvider)
                                .updateRide(ride.id, {'status': 'started'});
                            if (mounted) {
                              context.push('/ride-tracking/${ride.id}');
                            }
                          },
                        ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
