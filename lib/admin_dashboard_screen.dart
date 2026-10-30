import 'package:flutter/material.dart';
import 'user_session.dart';
import 'admin_trees_screen.dart';
import 'admin_users_screen.dart';
import 'admin_reports_screen.dart';
import 'login_screen.dart';
import 'api_service.dart';
import 'welcome_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String username;

  const AdminDashboardScreen({super.key, this.username = 'Administrator'});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color primaryColor = Color(0xFF3949AB);
  Map<String, dynamic> statistics = {};
  bool isLoadingStatistics = true;
  String? statisticsError;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      isLoadingStatistics = true;
      statisticsError = null;
    });

    try {
      final result = await ApiService.getReports();
      if (!mounted) return;

      setState(() {
        statistics = result;
        isLoadingStatistics = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingStatistics = false;
        statisticsError = 'Unable to load statistics: $e';
      });
    }
  }

  int _statValue(String key) {
    final value = statistics[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  // =====================================================
  // LOGOUT FUNCTION
  // =====================================================

  void _logout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () {
                UserSession.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        LoginScreen(nextScreen: const WelcomeScreen()),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Refresh button
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),

          // Logout button
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // WELCOME CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Welcome, ${widget.username}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage tree plantation activities and monitor '
                      'the application.',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'ADMINISTRATOR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Plantation Overview',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildStatistics(),
              const SizedBox(height: 25),

              // ADMINISTRATION HEADING
              const Text(
                'Administration',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              // MANAGE TREE RECORDS
              _AdminActionCard(
                icon: Icons.park,
                title: 'Manage Tree Records',
                subtitle: 'View online tree records from the REST API.',
                iconColor: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminTreesScreen(),
                    ),
                  );
                },
              ),

              // MANAGE USERS
              _AdminActionCard(
                icon: Icons.people,
                title: 'Manage Users',
                subtitle: 'View registered users and their roles.',
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminUsersScreen(),
                    ),
                  );
                },
              ),

              // REPORTS AND STATISTICS
              _AdminActionCard(
                icon: Icons.analytics,
                title: 'Reports and Statistics',
                subtitle: 'Review plantation activity and statistics.',
                iconColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminReportsScreen(),
                    ),
                  );
                },
              ),

              // ADMINISTRATION ACCESS
              _AdminActionCard(
                icon: Icons.security,
                title: 'Administration Access',
                subtitle: 'Check administrator permissions.',
                iconColor: Colors.deepPurple,
                onTap: () {
                  if (UserSession.isAdmin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Administrator access verified successfully.',
                        ),
                      ),
                    );
                  } else {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Administrator Access'),
                          content: const Text(
                            'This section is intended for users with '
                            'the ADMIN role.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // INFORMATION CARD
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: primaryColor,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'The administration interface is ready. '
                          'Tree records are connected to the REST API. '
                          'User management and reports are available.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    if (isLoadingStatistics) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (statisticsError != null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off, color: Colors.redAccent),
          title: Text(statisticsError!),
          trailing: IconButton(
            tooltip: 'Retry loading statistics',
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _DashboardStatCard(
          title: 'Trees',
          value: _statValue('total_trees'),
          icon: Icons.park,
          color: Colors.green,
        ),
        _DashboardStatCard(
          title: 'Users',
          value: _statValue('total_users'),
          icon: Icons.people,
          color: Colors.blue,
        ),
        _DashboardStatCard(
          title: 'Healthy',
          value: _statValue('healthy_trees'),
          icon: Icons.eco,
          color: Colors.teal,
        ),
        _DashboardStatCard(
          title: 'Need attention',
          value: _statValue('unhealthy_trees'),
          icon: Icons.warning_amber,
          color: Colors.orange,
        ),
      ],
    );
  }
}

// =====================================================
// REUSABLE ADMIN ACTION CARD
// =====================================================

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 27),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
