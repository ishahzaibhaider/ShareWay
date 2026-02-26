import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/ride/ride_card.dart';
import '../../widgets/common/loading_indicator.dart';

class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverRides = ref.watch(driverRidesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride History'),
      ),
      body: driverRides.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rides) {
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No ride history yet'),
                  const SizedBox(height: 8),
                  Text(
                    'Your past rides will appear here',
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
      ),
    );
  }
}
