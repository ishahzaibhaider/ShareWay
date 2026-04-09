import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/ride_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class HostRideScreen extends StatefulWidget {
  const HostRideScreen({super.key});
  @override
  State<HostRideScreen> createState() => _HostRideScreenState();
}

class _HostRideScreenState extends State<HostRideScreen> {
  final _pickupCtrl = TextEditingController(text: 'I-8 Markaz, Islamabad');
  final _destCtrl   = TextEditingController(text: 'COMSATS University');
  final _priceCtrl  = TextEditingController(text: '250');
  int _seats = 3;
  TimeOfDay _time = const TimeOfDay(hour: 7, minute: 30);
  DateTime _date = DateTime.now();
  bool _isRecurring = true;
  bool _isLoading = false;
  final Set<String> _selectedPrefs = {'AC On', 'Music OK'};

  static const List<String> _prefs = [
    '🎵 Music OK',
    '❄️ AC On',
    '🐾 Pets',
    '💬 Chat',
    '👩 Women Only',
    '🔇 Quiet',
  ];

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t != null) setState(() => _time = t);
  }

  String get _formattedTime => _time.format(context);

  Future<void> _postRide() async {
    // Basic validation
    if (_pickupCtrl.text.isEmpty || _destCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthService>().currentUser;
      final rideService = context.read<RideService>();

      if (user == null) {
        throw Exception('User not logged in');
      }

      final departureDateTime = DateTime(
        _date.year, _date.month, _date.day,
        _time.hour, _time.minute,
      );

      final rideId = await rideService.createRide(
        driverId: user.uid,
        pickup: _pickupCtrl.text,
        pickupLat: 33.6685, // Mock coordinates
        pickupLng: 73.0754,
        destination: _destCtrl.text,
        destLat: 33.6518,
        destLng: 73.1561,
        departureTime: departureDateTime,
        pricePerSeat: double.tryParse(_priceCtrl.text) ?? 0,
        availableSeats: _seats,
        preferences: _selectedPrefs.toList(),
        isRecurring: _isRecurring,
      );

      if (rideId != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🚗 Ride listed successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception('Failed to create ride');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: SwBackButton(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offer a Ride', style: AppTheme.titleL),
            Text('Share your journey · Earn money', style: AppTheme.caption),
          ],
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.sand,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Step 1/1', style: AppTheme.caption),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 1.0,
                minHeight: 4,
                backgroundColor: AppTheme.border,
                color: AppTheme.brandGreen,
              ),
            ),
            const SizedBox(height: 28),

            // ── Route ───────────────────────────────────────────────────
            Text('Route Details', style: AppTheme.titleL),
            const SizedBox(height: 14),
            SwFormField(
              label: 'Pickup Location',
              hint: 'Where do you start?',
              icon: Icons.trip_origin_rounded,
              controller: _pickupCtrl,
            ),
            const SizedBox(height: 14),
            SwFormField(
              label: 'Destination',
              hint: 'Where are you going?',
              icon: Icons.location_on_outlined,
              controller: _destCtrl,
            ),
            const SizedBox(height: 24),

            // ── Schedule ─────────────────────────────────────────────────
            Text('Schedule', style: AppTheme.titleL),
            const SizedBox(height: 14),
            Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.textSub),
                              const SizedBox(width: 8),
                              Text(
                                '${_date.day}/${_date.month}',
                                style: AppTheme.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Departure Time',
                        style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: AppTheme.textSub),
                              const SizedBox(width: 8),
                              Text(_formattedTime, style: AppTheme.body),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Recurring toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  const Icon(Icons.repeat_rounded, color: AppTheme.brandGreen, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recurring Ride', style: AppTheme.titleM),
                        Text('Repeat daily on weekdays', style: AppTheme.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (v) => setState(() => _isRecurring = v),
                    activeColor: AppTheme.brandGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Pricing & Seats ──────────────────────────────────────────
            Text('Pricing & Seats', style: AppTheme.titleL),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SwFormField(
                    label: 'Price per Seat (Rs)',
                    hint: '250',
                    icon: Icons.payments_outlined,
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Seats',
                        style: GoogleFonts.outfit(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StepButton(
                            icon: Icons.remove,
                            onTap: () => setState(() {
                              if (_seats > 1) _seats--;
                            }),
                          ),
                          Expanded(
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.sand,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '$_seats',
                                  style: AppTheme.displayM.copyWith(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                          _StepButton(
                            icon: Icons.add,
                            onTap: () => setState(() {
                              if (_seats < 6) _seats++;
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Preferences ──────────────────────────────────────────────
            Text('Ride Preferences', style: AppTheme.titleL),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _prefs.map((p) {
                final rawLabel = p.replaceAll(RegExp(r'[^\w\s]'), '').trim();
                final selected = _selectedPrefs.contains(rawLabel);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) _selectedPrefs.remove(rawLabel);
                    else _selectedPrefs.add(rawLabel);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.brandGreen.withOpacity(0.08)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppTheme.brandGreen : AppTheme.border,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      p,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppTheme.brandGreen : AppTheme.textSub,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _postRide,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('🚀  Post Ride Listing'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textMain),
      ),
    );
  }
}
