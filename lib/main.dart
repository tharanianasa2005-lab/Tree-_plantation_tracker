import 'package:flutter/material.dart';
import 'add_tree_screen.dart';

void main() {
  runApp(const TreePlantationTracker());
}

class TreePlantationTracker extends StatelessWidget {
  const TreePlantationTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tree Plantation Tracker',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),

      home: const DashboardScreen(),
    );
  }
}

// ------------------------------------------------------------
// DASHBOARD
// ------------------------------------------------------------

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  void openAddTreeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTreeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),

      // ------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------

      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

        title: const Text(
          '🌱 Tree Plantation Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No new notifications 🔔',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
        ],
      ),

      // ------------------------------------------------------
      // BODY
      // ------------------------------------------------------

      body: _buildCurrentPage(),

      // ------------------------------------------------------
      // BOTTOM NAVIGATION
      // ------------------------------------------------------

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        selectedItemColor: Colors.green,

        unselectedItemColor: Colors.grey,

        type: BottomNavigationBarType.fixed,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.forest),
            label: 'My Trees',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PAGE SELECTION
  // ------------------------------------------------------------

  Widget _buildCurrentPage() {
    switch (selectedIndex) {
      case 0:
        return _buildHomePage();

      case 1:
        return _buildMyTreesPage();

      case 2:
        return _buildMapPage();

      case 3:
        return _buildProfilePage();

      default:
        return _buildHomePage();
    }
  }

  // ------------------------------------------------------------
  // HOME PAGE
  // ------------------------------------------------------------

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const SizedBox(height: 5),

          const Text(
            'Welcome! 🌱',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Track your trees and make the planet greener.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // --------------------------------------------------
          // STATISTICS
          // --------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.forest,
                  title: 'Total Trees',
                  value: '0',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  icon: Icons.favorite,
                  title: 'Healthy',
                  value: '0',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _statCard(
                  icon: Icons.location_on,
                  title: 'Locations',
                  value: '0',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _statCard(
                  icon: Icons.eco,
                  title: 'CO₂ Impact',
                  value: '0 kg',
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // ADD TREE BUTTON
          // --------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 58,

            child: ElevatedButton.icon(
              onPressed: openAddTreeScreen,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add New Tree',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // QUICK ACTIONS
          // --------------------------------------------------

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.forest,
                  title: 'My Trees',
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _actionCard(
                  icon: Icons.map,
                  title: 'Plantation Map',
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _actionCard(
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Statistics will be available after Firebase integration.',
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _actionCard(
                  icon: Icons.notifications,
                  title: 'Reminders',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Reminders will be added later.',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // --------------------------------------------------
          // RECENT ACTIVITY
          // --------------------------------------------------

          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,

            padding: const EdgeInsets.all(25),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(15),
            ),

            child: const Column(
              children: [
                Icon(
                  Icons.forest_outlined,
                  size: 55,
                  color: Colors.green,
                ),

                SizedBox(height: 10),

                Text(
                  'No trees added yet',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Start by adding your first planted tree.',
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // MY TREES PAGE
  // ------------------------------------------------------------

  Widget _buildMyTreesPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.forest,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              'My Trees',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your planted trees will appear here.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: openAddTreeScreen,

              icon: const Icon(
                Icons.add,
              ),

              label: const Text(
                'Add First Tree',
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MAP PAGE
  // ------------------------------------------------------------

  Widget _buildMapPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.map,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              'Plantation Map',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Your planted trees will be displayed on the map here.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '📍 GPS + Google Maps will be added next.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFILE PAGE
  // ------------------------------------------------------------

  Widget _buildProfilePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const CircleAvatar(
              radius: 50,

              backgroundColor: Colors.green,

              child: Icon(
                Icons.person,
                size: 55,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'User Profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Login and profile management will be added with Firebase.',
              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STAT CARD
  // ------------------------------------------------------------

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: Colors.green,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION CARD
  // ------------------------------------------------------------

  Widget _actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(15),

      child: Container(
        height: 115,

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(15),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 38,
              color: Colors.green,
            ),

            const SizedBox(height: 10),

            Text(
              title,

              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}