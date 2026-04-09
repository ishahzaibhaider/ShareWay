import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/ride.dart';
import '../services/auth_service.dart';
import '../services/ride_service.dart';
import '../theme.dart';
import '../widgets/shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  int _selectedCategory = 0;
  final _searchCtrl = TextEditingController();
  final List<String> _categories = ['All Rides', 'Economy', 'Premium', 'Women Only', 'Daily'];

  String? get _categoryFilter {
    if (_selectedCategory == 0) return 'all';
    final map = {1: 'economy', 2: 'premium', 3: 'women', 4: 'daily'};
    return map[_selectedCategory];
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final rideService = context.watch<RideService>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(user),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => setState(() {}),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(user),
                      _buildSearchBar(),
                      _buildCategoryRow(),
                      _buildQuickActions(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: SwSectionHeader(
                          'Available Near You',
                          action: 'See all',
                        ),
                      ),
                      FutureBuilder<List<Ride>>(
                        future: rideService.getAvailableRides(category: _categoryFilter),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final rides = snapshot.data ?? [];
                          if (rides.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Text('No rides found.', style: AppTheme.body),
                              ),
                            );
                          }

                          return Column(
                            children: rides.map((r) => _buildRideCard(r)).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/host'),
        backgroundColor: AppTheme.brandGreen,
        icon: const Icon(Icons.add_road_rounded, color: Colors.white),
        label: Text(
          'Offer a Ride',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader(SwUser? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Share',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMain,
                  ),
                ),
                TextSpan(
                  text: 'Way',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.brandGreen,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Notification Bell
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: AppTheme.textMain,
            ),
          ),
          // Profile Avatar
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.sand,
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&h=200&fit=crop'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(SwUser? user) {
    final firstName = user?.name.split(' ').first ?? 'there';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, $firstName 👋',
            style: AppTheme.caption.copyWith(color: AppTheme.textSub, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text('Where are you\nheading today?', style: AppTheme.displayL),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppTheme.brandGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search destination...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                filled: false,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.brandGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final selected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: selected
                ? AppTheme.gradient3D([AppTheme.brandGreen, AppTheme.brandGreenLt])
                : BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.border),
                  ),
              child: Text(
                _categories[i],
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textSub,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionCard(
              icon: Icons.add_road_rounded,
              title: 'Offer a Ride',
              subtitle: 'Share your journey',
              color: AppTheme.brandGreen,
              onTap: () => Navigator.pushNamed(context, '/host'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionCard(
              icon: Icons.turned_in_not_rounded,
              title: 'Saved Routes',
              subtitle: 'Home · COMSATS',
              color: AppTheme.accent,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final List<String> avatars = [
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop',
    ];
    final avatar = avatars[ride.id.hashCode % avatars.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Sw3DCard(
        onTap: () => Navigator.pushNamed(context, '/ride_details', arguments: ride),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Driver Avatar with Verified Badge
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.sand,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.verified_rounded, size: 16, color: AppTheme.success),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ride.destination,
                          style: AppTheme.titleM,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(ride.driverName, style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600, color: AppTheme.brandGreen)),
                      const SizedBox(width: 4),
                      Text('•', style: AppTheme.caption),
                      const SizedBox(width: 4),
                      Text(ride.carModel, style: AppTheme.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppTheme.textSub),
                      const SizedBox(width: 4),
                      Text(ride.departureTime, style: AppTheme.caption),
                      const Spacer(),
                      SwStarRating(ride.rating),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${ride.price.toInt()}',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.brandGreen,
                  ),
                ),
                Text('/ seat', style: AppTheme.caption.copyWith(fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (i) {
        setState(() => _currentNavIndex = i);
        if (i == 2) Navigator.pushNamed(context, '/chat');
        if (i == 3) Navigator.pushNamed(context, '/wallet');
        if (i == 4) Navigator.pushNamed(context, '/profile');
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore_rounded),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline_rounded),
          activeIcon: Icon(Icons.chat_bubble_rounded),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet_rounded),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline_rounded),
          activeIcon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({
    required this.icon, required this.title,
    required this.subtitle, required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Sw3DCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sw3DIcon(icon: icon, baseColor: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: AppTheme.titleM),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTheme.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
