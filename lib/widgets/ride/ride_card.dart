import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/ride_model.dart';

class RideCard extends StatelessWidget {
  final RideModel ride;
  final double? matchScore;
  final VoidCallback onTap;

  const RideCard({
    super.key,
    required this.ride,
    this.matchScore,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver info row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      ride.driverName.isNotEmpty
                          ? ride.driverName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              ride.driverRating.toStringAsFixed(1),
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Match score badge
                  if (matchScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getScoreColor(matchScore!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(matchScore! * 100).toInt()}% Match',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const Divider(height: 24),

              // Route info
              _buildLocationRow(
                Icons.circle_outlined,
                AppTheme.primaryColor,
                ride.origin.address,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 11),
                child: Container(
                  width: 2,
                  height: 20,
                  color: AppTheme.dividerColor,
                ),
              ),
              _buildLocationRow(
                Icons.location_on,
                AppTheme.accentColor,
                ride.destination.address,
              ),
              const SizedBox(height: 12),

              // Details row
              Row(
                children: [
                  _buildInfoChip(
                    Icons.access_time,
                    DateFormat('hh:mm a').format(ride.departureTime),
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.event_seat,
                    '${ride.availableSeats} seats',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.attach_money,
                    'Rs. ${ride.estimatedFare.toStringAsFixed(0)}',
                  ),
                ],
              ),
              if (ride.paymentMethods.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: ride.paymentMethods.map((method) {
                    return Chip(
                      label: Text(method, style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
