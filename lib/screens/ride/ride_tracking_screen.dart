import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rides_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RideTrackingScreen({super.key, required this.rideId});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription? _locationSubscription;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() {
    final locationService = ref.read(locationServiceProvider);
    _locationSubscription = locationService.getPositionStream().listen((pos) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_currentPosition!),
      );
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

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

          return Stack(
            children: [
              // Full screen map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(ride.origin.lat, ride.origin.lng),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                markers: {
                  Marker(
                    markerId: const MarkerId('origin'),
                    position: LatLng(ride.origin.lat, ride.origin.lng),
                    infoWindow: const InfoWindow(title: 'Pickup'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position:
                        LatLng(ride.destination.lat, ride.destination.lng),
                    infoWindow: const InfoWindow(title: 'Dropoff'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                  if (_currentPosition != null)
                    Marker(
                      markerId: const MarkerId('current'),
                      position: _currentPosition!,
                      infoWindow: const InfoWindow(title: 'You'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue),
                    ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),

              // Bottom panel
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_car,
                              color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.status == 'started'
                                      ? 'Ride in Progress'
                                      : 'Ride ${ride.status}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${ride.passengers.where((p) => p.status == 'accepted').length} passenger(s)',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // Chat button
                          IconButton(
                            onPressed: () {
                              // Navigate to chat with the other party
                            },
                            icon: const Icon(Icons.chat_bubble_outline,
                                color: AppTheme.primaryColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (isDriver && ride.status == 'started')
                        CustomButton(
                          text: 'Complete Ride',
                          icon: Icons.check_circle,
                          onPressed: _completeRide,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
