import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/rides_provider.dart';
import '../../services/maps/osm_service.dart';
import '../../widgets/ride/ride_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/map_location_picker.dart';

final osmServiceProvider = Provider((ref) => OsmService());

class FindRideScreen extends ConsumerStatefulWidget {
  const FindRideScreen({super.key});

  @override
  ConsumerState<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends ConsumerState<FindRideScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  DateTime _selectedTime = DateTime.now();

  PlaceDetails? _pickupPlace;
  PlaceDetails? _dropoffPlace;

  bool _hasSearched = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _searchRides() async {
    if (_pickupPlace == null || _dropoffPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and dropoff locations')),
      );
      return;
    }

    setState(() => _hasSearched = true);

    await ref.read(matchingRidesProvider.notifier).findMatches(
          pickupLat: _pickupPlace!.lat,
          pickupLng: _pickupPlace!.lng,
          dropoffLat: _dropoffPlace!.lat,
          dropoffLng: _dropoffPlace!.lng,
          departureTime: _selectedTime,
        );
  }

  Future<void> _showLocationPicker(bool isPickup) async {
    final osmService = ref.read(osmServiceProvider);

    final result = await Navigator.of(context).push<PlaceDetails>(
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          osmService: osmService,
          title: isPickup ? 'Select Pickup Location' : 'Select Dropoff Location',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isPickup) {
          _pickupPlace = result;
          _pickupController.text = result.address.split(',').take(2).join(', ');
        } else {
          _dropoffPlace = result;
          _dropoffController.text = result.address.split(',').take(2).join(', ');
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (time != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchingRides = ref.watch(matchingRidesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Ride'),
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
            ),
            child: Column(
              children: [
                // Pickup
                TextField(
                  controller: _pickupController,
                  readOnly: true,
                  onTap: () => _showLocationPicker(true),
                  decoration: InputDecoration(
                    hintText: 'Pickup location',
                    prefixIcon: Icon(Icons.circle_outlined,
                        color: AppTheme.primaryColor, size: 18),
                    suffixIcon: _pickupPlace != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _pickupController.clear();
                                _pickupPlace = null;
                              });
                            },
                          )
                        : const Icon(Icons.map_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // Dropoff
                TextField(
                  controller: _dropoffController,
                  readOnly: true,
                  onTap: () => _showLocationPicker(false),
                  decoration: InputDecoration(
                    hintText: 'Dropoff location',
                    prefixIcon: Icon(Icons.location_on,
                        color: AppTheme.accentColor, size: 18),
                    suffixIcon: _dropoffPlace != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _dropoffController.clear();
                                _dropoffPlace = null;
                              });
                            },
                          )
                        : const Icon(Icons.map_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 10),

                // Time + Search
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(
                          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _searchRides,
                        icon: const Icon(Icons.search),
                        label: const Text('Search Rides'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search,
                            size: 64, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Search for available rides',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : matchingRides.when(
                    loading: () =>
                        const LoadingIndicator(message: 'Finding best rides...'),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.no_transfer,
                                  size: 64, color: Colors.white.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('No matching rides found'),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your time or locations',
                                style:
                                    TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final result = results[index];
                          return RideCard(
                            ride: result.ride,
                            matchScore: result.score,
                            onTap: () {
                              context.push('/ride/${result.ride.id}');
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
