import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/rating_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rides_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String rideId;

  const RatingScreen({super.key, required this.rideId});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  double _rating = 4.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating(String toUserId, String rideType) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final rating = RatingModel(
        id: '',
        fromUserId: user.uid,
        fromUserName: user.name,
        toUserId: toUserId,
        rideId: widget.rideId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        rideType: rideType,
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createRating(rating);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanks for your rating!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(rideStreamProvider(widget.rideId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Your Ride')),
      body: rideAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ride) {
          if (ride == null) {
            return const Center(child: Text('Ride not found'));
          }

          final isDriver = currentUser?.uid == ride.driverId;
          final toUserId = isDriver
              ? (ride.passengers.isNotEmpty
                  ? ride.passengers.first.passengerId
                  : '')
              : ride.driverId;
          final ratingFor = isDriver ? 'passenger' : 'driver';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.check_circle,
                    size: 80, color: AppTheme.primaryColor),
                const SizedBox(height: 16),
                const Text(
                  'Ride Completed!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'How was your ${isDriver ? "passenger" : "driver"}?',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Rating stars
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 48,
                  itemPadding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() => _rating = rating);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _getRatingLabel(_rating),
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Comment
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Leave a comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: 'Submit Rating',
                  isLoading: _isLoading,
                  onPressed: toUserId.isNotEmpty
                      ? () => _submitRating(toUserId, ratingFor)
                      : () => context.go('/'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Skip'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent!';
    if (rating >= 3.5) return 'Great';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    return 'Poor';
  }
}
