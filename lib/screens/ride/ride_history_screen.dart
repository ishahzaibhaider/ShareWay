import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/ride_model.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/ride/ride_card.dart';
import '../../widgets/common/loading_indicator.dart';

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverRides = ref.watch(driverRidesProvider);
    final passengerRides = ref.watch(passengerRidesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ride History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'As Driver'),
              Tab(text: 'As Passenger'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRideList(context, driverRides, 'driver'),
            _buildRideList(context, passengerRides, 'passenger'),
          ],
        ),
      ),
    );
  }

  Widget _buildRideList(
    BuildContext context,
    AsyncValue<List<RideModel>> ridesAsync,
    String type,
  ) {
    return ridesAsync.when(
      loading: () => const LoadingIndicator(),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (rides) {
        if (rides.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type == 'driver' ? Icons.directions_car : Icons.hail,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(type == 'driver'
                    ? 'No rides offered yet'
                    : 'No rides taken yet'),
                const SizedBox(height: 8),
                Text(
                  type == 'driver'
                      ? 'Rides you offer will appear here'
                      : 'Rides you join will appear here',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: rides.length,
          itemBuilder: (context, index) {
            return RideCard(
              ride: rides[index],
              onTap: () => context.push('/ride/${rides[index].id}'),
            );
          },
        );
      },
    );
  }
}
