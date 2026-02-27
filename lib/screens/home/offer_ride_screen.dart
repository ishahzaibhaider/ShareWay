import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/app_constants.dart';
import '../../models/ride_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rides_provider.dart';
import '../../services/maps/osm_service.dart';
import '../../widgets/common/custom_button.dart';
import '../home/find_ride_screen.dart';

class OfferRideScreen extends ConsumerStatefulWidget {
  const OfferRideScreen({super.key});

  @override
  ConsumerState<OfferRideScreen> createState() => _OfferRideScreenState();
}

class _OfferRideScreenState extends ConsumerState<OfferRideScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  PlaceDetails? _originPlace;
  PlaceDetails? _destinationPlace;

  DateTime _departureDate = DateTime.now();
  TimeOfDay _departureTime = TimeOfDay.now();
  int _availableSeats = 3;
  String _rideType = 'onetime';
  final List<String> _selectedDays = [];
  final List<String> _selectedPaymentMethods = ['Cash'];
  bool _isLoading = false;

  final _daysOfWeek = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _showPlacePicker(bool isOrigin) async {
    final osmService = ref.read(osmServiceProvider);
    final controller = isOrigin ? _originController : _destinationController;

    final result = await showModalBottomSheet<PlaceDetails>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PlaceSearchSheet(osmService: osmService),
    );

    if (result != null) {
      setState(() {
        controller.text = result.address;
        if (isOrigin) {
          _originPlace = result;
        } else {
          _destinationPlace = result;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _departureDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _departureTime,
    );
    if (time != null) setState(() => _departureTime = time);
  }

  Future<void> _createRide() async {
    if (_originPlace == null || _destinationPlace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select origin and destination')),
      );
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final osmService = ref.read(osmServiceProvider);

      // Get directions for route info via OSRM
      final directions = await osmService.getDirections(
        originLat: _originPlace!.lat,
        originLng: _originPlace!.lng,
        destLat: _destinationPlace!.lat,
        destLng: _destinationPlace!.lng,
      );

      final departureDateTime = DateTime(
        _departureDate.year,
        _departureDate.month,
        _departureDate.day,
        _departureTime.hour,
        _departureTime.minute,
      );

      final distanceKm = directions != null
          ? directions.distanceMeters / 1000
          : 0.0;
      final fare = distanceKm * AppConstants.defaultFarePerKm;

      final ride = RideModel(
        id: '',
        driverId: user.uid,
        driverName: user.name,
        driverRating: user.averageRating,
        driverPhoto: user.profilePhoto,
        origin: LocationPoint(
          lat: _originPlace!.lat,
          lng: _originPlace!.lng,
          address: _originPlace!.address,
          placeId: _originPlace!.placeId,
        ),
        destination: LocationPoint(
          lat: _destinationPlace!.lat,
          lng: _destinationPlace!.lng,
          address: _destinationPlace!.address,
          placeId: _destinationPlace!.placeId,
        ),
        departureTime: departureDateTime,
        availableSeats: _availableSeats,
        totalSeats: _availableSeats,
        routePolyline: null,
        estimatedDistance: distanceKm,
        estimatedFare: fare,
        rideType: _rideType,
        recurringDays: _rideType == 'recurring' ? _selectedDays : [],
        paymentMethods: _selectedPaymentMethods,
      );

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.createRide(ride);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _originController.clear();
        _destinationController.clear();
        setState(() {
          _originPlace = null;
          _destinationPlace = null;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer a Ride'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Origin
            TextField(
              controller: _originController,
              readOnly: true,
              onTap: () => _showPlacePicker(true),
              decoration: InputDecoration(
                labelText: 'From',
                hintText: 'Select origin',
                prefixIcon: Icon(Icons.circle_outlined,
                    color: AppTheme.primaryColor, size: 18),
              ),
            ),
            const SizedBox(height: 12),

            // Destination
            TextField(
              controller: _destinationController,
              readOnly: true,
              onTap: () => _showPlacePicker(false),
              decoration: InputDecoration(
                labelText: 'To',
                hintText: 'Select destination',
                prefixIcon: Icon(Icons.location_on,
                    color: AppTheme.accentColor, size: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Date & Time Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(DateFormat('MMM dd').format(_departureDate)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time, size: 18),
                    label: Text(_departureTime.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Available Seats
            Text('Available Seats',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(4, (index) {
                final seats = index + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _availableSeats = seats),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _availableSeats == seats
                            ? AppTheme.primaryColor
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.event_seat,
                              color: _availableSeats == seats
                                  ? Colors.white
                                  : AppTheme.textSecondary),
                          const SizedBox(height: 4),
                          Text(
                            '$seats',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _availableSeats == seats
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Ride Type
            Text('Ride Type',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'onetime', label: Text('One-time')),
                ButtonSegment(value: 'recurring', label: Text('Recurring')),
              ],
              selected: {_rideType},
              onSelectionChanged: (value) {
                setState(() => _rideType = value.first);
              },
            ),

            // Recurring days
            if (_rideType == 'recurring') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: _daysOfWeek.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),

            // Payment Methods
            Text('Accepted Payment Methods',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: AppConstants.paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethods.contains(method);
                return FilterChip(
                  label: Text(method),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPaymentMethods.add(method);
                      } else {
                        if (_selectedPaymentMethods.length > 1) {
                          _selectedPaymentMethods.remove(method);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Create Ride Button
            CustomButton(
              text: 'Create Ride',
              isLoading: _isLoading,
              icon: Icons.add_circle_outline,
              onPressed: _createRide,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
