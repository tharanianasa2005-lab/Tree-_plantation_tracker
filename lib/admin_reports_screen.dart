import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  Map<String, dynamic> statistics = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getReports();

      if (!mounted) return;

      setState(() {
        statistics = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load reports: $e';
      });
    }
  }

  int getCount(String key) {
    final value = statistics[key];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports and Statistics',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3949AB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            onPressed: loadReports,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: loadReports,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadReports,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Plantation Overview',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live statistics retrieved from your MySQL database.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          _statCard(
            title: 'Total Trees',
            value: getCount('total_trees'),
            icon: Icons.park,
            color: Colors.green,
          ),
          _statCard(
            title: 'Registered Users',
            value: getCount('total_users'),
            icon: Icons.people,
            color: Colors.blue,
          ),
          _statCard(
            title: 'Administrators',
            value: getCount('total_admins'),
            icon: Icons.admin_panel_settings,
            color: Colors.deepPurple,
          ),
          _statCard(
            title: 'Regular Users',
            value: getCount('total_regular_users'),
            icon: Icons.person,
            color: Colors.teal,
          ),
          _statCard(
            title: 'Healthy Trees',
            value: getCount('healthy_trees'),
            icon: Icons.eco,
            color: Colors.green,
          ),
          _statCard(
            title: 'Unhealthy Trees',
            value: getCount('unhealthy_trees'),
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),

          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF3949AB)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Statistics reflect the records currently stored '
                      'in the database. Pull down to refresh.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text('Database total'),
        trailing: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
