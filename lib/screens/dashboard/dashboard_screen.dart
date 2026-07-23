import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/confirmation_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTab = 0;

  // Simple stats count definitions (mock data)
  final int activeBuses = 12;
  final int totalDrivers = 8;
  final int totalParents = 145;
  final int totalRoutes = 6;
  final int todayTrips = 24;

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ConfirmationDialog(
        title: 'Logout Confirm',
        content: 'Are you sure you want to end your session and log out?',
        confirmText: 'Logout',
        confirmColor: AppTheme.errorColor,
        onConfirm: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final userName = user?.fullName ?? 'User';
    final userRole = user?.role ?? 'Parent';

    // Track user activity on any tap or gesture on the screen
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => authProvider.recordActivity(),
      onPanDown: (_) => authProvider.recordActivity(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RouteSafe'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {
                authProvider.recordActivity();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications.')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _handleLogout(context),
            )
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                accountName: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(
                  'Role: $userRole',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryColor),
                title: const Text('Dashboard'),
                selected: _currentTab == 0,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentTab = 0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_bus_filled_outlined, color: AppTheme.primaryColor),
                title: const Text('Manage Buses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.busCrud);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: AppTheme.primaryColor),
                title: const Text('Profile'),
                selected: _currentTab == 2,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentTab = 2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined, color: AppTheme.primaryColor),
                title: const Text('Settings'),
                selected: _currentTab == 3,
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentTab = 3);
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
                title: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(context);
                  _handleLogout(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        body: _buildTabBody(userName, userRole),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textLight,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            authProvider.recordActivity();
            setState(() {
              _currentTab = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Live Track',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(String name, String role) {
    switch (_currentTab) {
      case 0:
        return _buildHomeTab(name, role);
      case 1:
        return _buildMapTab();
      case 2:
        return _buildProfileTab(name, role);
      case 3:
        return _buildSettingsTab();
      default:
        return _buildHomeTab(name, role);
    }
  }

  Widget _buildHomeTab(String name, String role) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xff1d4ed8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Role: $role',
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Grid Header
          Text(
            'System Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 12),

          // Statistics Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                title: 'Active Buses',
                value: '$activeBuses',
                icon: Icons.directions_bus_outlined,
                color: const Color(0xff3b82f6),
              ),
              _buildStatCard(
                title: 'Drivers Registered',
                value: '$totalDrivers',
                icon: Icons.badge_outlined,
                color: const Color(0xff10b981),
              ),
              _buildStatCard(
                title: 'Parents Enrolled',
                value: '$totalParents',
                icon: Icons.people_alt_outlined,
                color: const Color(0xfff59e0b),
              ),
              _buildStatCard(
                title: 'Active Routes',
                value: '$totalRoutes',
                icon: Icons.alt_route_outlined,
                color: const Color(0xff8b5cf6),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Actions Header
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 12),

          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Bus Management',
                  subtitle: 'Add, edit, remove school buses',
                  icon: Icons.directions_bus_filled_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.busCrud),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  title: 'Tracking Map',
                  subtitle: 'View live routes on map',
                  icon: Icons.map_rounded,
                  color: AppTheme.accentColor,
                  onTap: () => setState(() => _currentTab = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity Header
          Text(
            "Today's Trips & Activity",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
          ),
          const SizedBox(height: 12),

          // Activity List
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildActivityTile(
                title: 'Bus 03 (Reg NY-8890) has started Route A',
                time: '10 mins ago',
                icon: Icons.play_circle_outline_rounded,
                iconColor: AppTheme.successColor,
              ),
              _buildActivityTile(
                title: 'Bus 12 completed morning drop-off safely',
                time: '1 hour ago',
                icon: Icons.check_circle_outline_rounded,
                iconColor: AppTheme.primaryColor,
              ),
              _buildActivityTile(
                title: 'Driver John Doe assigned to Bus 08',
                time: '2 hours ago',
                icon: Icons.person_add_alt_1_outlined,
                iconColor: const Color(0xff8b5cf6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark.withOpacity(0.8),
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isYellow = color == AppTheme.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: isYellow ? const Color(0xffb45309) : color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textDark),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  // Live Track Mock Tab
  Widget _buildMapTab() {
    return Container(
      color: const Color(0xfff1f5f9),
      child: Stack(
        children: [
          // Branded Mock Map UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_rounded,
                  size: 80,
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Live Tracking Map View',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Simulated real-time bus tracking coordinates',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          // Floating Bus Markers Mock overlay
          Positioned(
            top: 100,
            left: 80,
            child: _buildMapBusMarker('Bus 03', Colors.green),
          ),
          Positioned(
            top: 250,
            right: 90,
            child: _buildMapBusMarker('Bus 12', AppTheme.primaryColor),
          ),
          Positioned(
            bottom: 120,
            left: 140,
            child: _buildMapBusMarker('Bus 08', Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBusMarker(String name, Color markerColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.directions_bus_filled_rounded, color: markerColor, size: 16),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }

  // Profile Tab
  Widget _buildProfileTab(String name, String role) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.accentColor,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                Text(
                  'Registered role: $role',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildProfileInfoRow(Icons.email_outlined, 'Email', 'admin@routesafe.com'),
                const SizedBox(height: 12),
                _buildProfileInfoRow(Icons.phone_outlined, 'Contact', '+1 (555) 019-2834'),
                const SizedBox(height: 12),
                _buildProfileInfoRow(Icons.domain_outlined, 'Organization', 'RouteSafe Academy'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
            ),
          ],
        )
      ],
    );
  }

  // Settings Tab
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryColor),
                title: const Text('Push Notifications'),
                trailing: Switch(
                  value: true,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) {},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                title: const Text('High Accuracy Location'),
                trailing: Switch(
                  value: true,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) {},
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security_outlined, color: AppTheme.primaryColor),
                title: const Text('Biometric Login'),
                trailing: Switch(
                  value: false,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline_rounded, color: AppTheme.primaryColor),
                title: const Text('Help Center'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
                title: const Text('About RouteSafe v1.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        )
      ],
    );
  }
}
