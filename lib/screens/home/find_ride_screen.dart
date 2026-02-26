import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../providers/rides_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/maps/google_maps_service.dart';
import '../../widgets/ride/ride_card.dart';
import '../../widgets/common/loading_indicator.dart';

final googleMapsServiceProvider = Provider((ref) => GoogleMapsService());

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

  Future<void> _showPlacePicker(bool isPickup) async {
    final mapsService = ref.read(googleMapsServiceProvider);
    final controller = isPickup ? _pickupController : _dropoffController;

    final result = await showModalBottomSheet<PlaceDetails>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _PlaceSearchSheet(mapsService: mapsService),
    );

    if (result != null) {
      setState(() {
        controller.text = result.address;
        if (isPickup) {
          _pickupPlace = result;
        } else {
          _dropoffPlace = result;
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
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Pickup
                TextField(
                  controller: _pickupController,
                  readOnly: true,
                  onTap: () => _showPlacePicker(true),
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
                        : null,
                  ),
                ),
                const SizedBox(height: 10),

                // Dropoff
                TextField(
                  controller: _dropoffController,
                  readOnly: true,
                  onTap: () => _showPlacePicker(false),
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
                        : null,
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
                            size: 64, color: Colors.grey.shade300),
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
                                  size: 64, color: Colors.grey.shade300),
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

// Place search bottom sheet
class _PlaceSearchSheet extends StatefulWidget {
  final GoogleMapsService mapsService;

  const _PlaceSearchSheet({required this.mapsService});

  @override
  State<_PlaceSearchSheet> createState() => _PlaceSearchSheetState();
}

class _PlaceSearchSheetState extends State<_PlaceSearchSheet> {
  final _searchController = TextEditingController();
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.length < 3) {
      setState(() => _predictions = []);
      return;
    }

    setState(() => _isLoading = true);
    final results = await widget.mapsService.getPlacePredictions(query);
    setState(() {
      _predictions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _search,
                decoration: const InputDecoration(
                  hintText: 'Search for a place...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _predictions.length,
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(prediction.mainText),
                    subtitle: Text(
                      prediction.secondaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final details = await widget.mapsService
                          .getPlaceDetails(prediction.placeId);
                      if (details != null && context.mounted) {
                        Navigator.of(context).pop(details);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
