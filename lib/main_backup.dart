import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'welcome_screen.dart';
import 'intro_screen.dart';
import 'login_screen.dart';
import 'add_tree_screen.dart';
import 'api_service.dart';

// ============================================================
// MAIN
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TreePlantationTracker());
}

// ============================================================
// MAIN APP
// ============================================================
class TreePlantationTracker extends StatelessWidget {
  const TreePlantationTracker({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tree Plantation Tracker',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F9F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 76, 130, 175),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 175, 76, 168),
        ),
        useMaterial3: true,
      ),
      // ðŸŒ³ Intro â†’ Login â†’ Dashboard
      home: const IntroScreen(nextScreen: DashboardScreen()),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  final List<Widget> pages = const [
    HomePage(),
    MyTreesPage(),
    MapPage(),
    ProfilePage(),
  ];
  // ==========================================================
  // OPEN ADD TREE SCREEN
  // ==========================================================
  Future<void> openAddTreeScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTreeScreen()),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      // ======================================================
      // ADD TREE BUTTON
      // ======================================================
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: openAddTreeScreen,
              backgroundColor: const Color.fromARGB(255, 82, 192, 219),
              foregroundColor: const Color.fromARGB(255, 255, 255, 255),
              icon: const Icon(Icons.add),
              label: const Text('Add New Tree'),
            )
          : null,
      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.park_outlined),
            selectedIcon: Icon(Icons.park),
            label: 'My Trees',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalTrees = 0;
  int healthyTrees = 0;
  int locations = 0;
  int thisMonth = 0;
  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  // ==========================================================
  // LOAD DASHBOARD DATA FROM THE SERVER
  // ==========================================================
  Future<void> loadDashboardData() async {
    try {
      final trees = await ApiService.getTrees();
      int healthy = 0;
      int monthCount = 0;
      final Set<String> uniqueLocations = {};
      final now = DateTime.now();
      for (final tree in trees) {
        // HEALTHY TREES
        if (tree['health_status'] == 'Healthy') {
          healthy++;
        }
        // UNIQUE LOCATIONS
        final location = tree['location_text'];
        if (location != null &&
            location.toString().isNotEmpty &&
            location.toString() != 'Location not selected') {
          uniqueLocations.add(location.toString());
        }
        // TREES PLANTED THIS MONTH
        final plantedDate = tree['planted_date'];
        if (plantedDate != null) {
          try {
            final date = DateTime.parse(plantedDate.toString());
            if (date.year == now.year && date.month == now.month) {
              monthCount++;
            }
          } catch (_) {
            // Ignore invalid date
          }
        }
      }
      if (!mounted) return;
      setState(() {
        totalTrees = trees.length;
        healthyTrees = healthy;
        locations = uniqueLocations.length;
        thisMonth = monthCount;
      });
    } catch (e) {
      debugPrint('Dashboard server error: $e');
    }
  }

  // ==========================================================
  // OPEN ADD TREE
  // ==========================================================
  Future<void> openAddTree() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTreeScreen()),
    );
    if (result == true) {
      await loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadDashboardData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ==================================================
            // APP BAR
            // ==================================================
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 76, 99, 175),
              expandedHeight: 150,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'Tree Plantation Tracker',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  color: const Color.fromARGB(255, 175, 76, 129),
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 25),
                      child: Icon(
                        Icons.forest,
                        size: 70,
                        color: Color.fromARGB(60, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // ==================================================
            // HOME CONTENT
            // ==================================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    'Welcome! ðŸŒ±',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Track and manage your planted trees easily.',
                    style: TextStyle(
                      color: Color.fromARGB(255, 158, 158, 158),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ==================================================
                  // STATISTICS
                  // ==================================================
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.park,
                          title: 'Trees',
                          value: totalTrees.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.eco,
                          title: 'Healthy',
                          value: healthyTrees.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.location_on,
                          title: 'Locations',
                          value: locations.toString(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_month,
                          title: 'This Month',
                          value: thisMonth.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  // ==================================================
                  // QUICK ACTIONS
                  // ==================================================
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionCard(
                    icon: Icons.add_circle,
                    title: 'Add New Tree',
                    subtitle: 'Record a newly planted tree',
                    onTap: openAddTree,
                  ),
                  _QuickActionCard(
                    icon: Icons.park,
                    title: 'View My Trees',
                    subtitle: 'See all your planted trees',
                    onTap: () {
                      final dashboard = context
                          .findAncestorStateOfType<_DashboardScreenState>();
                      dashboard?.setState(() {
                        dashboard.currentIndex = 1;
                      });
                    },
                  ),
                  _QuickActionCard(
                    icon: Icons.map,
                    title: 'Plantation Map',
                    subtitle: 'View tree locations',
                    onTap: () {
                      final dashboard = context
                          .findAncestorStateOfType<_DashboardScreenState>();
                      dashboard?.setState(() {
                        dashboard.currentIndex = 2;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // ==================================================
                  // RECENT ACTIVITY
                  // ==================================================
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: totalTrees == 0
                          ? const Column(
                              children: [
                                Icon(
                                  Icons.eco_outlined,
                                  size: 45,
                                  color: Color.fromARGB(255, 76, 168, 175),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'No trees added yet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Start planting and record your first tree.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 158, 158, 158),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const Icon(
                                  Icons.park,
                                  size: 45,
                                  color: Color.fromARGB(255, 76, 135, 175),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '$totalTrees tree${totalTrees == 1 ? '' : 's'} recorded',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Your plantation records are saved locally.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 158, 158, 158),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color.fromARGB(255, 109, 76, 175),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(color: Color.fromARGB(211, 158, 158, 158)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUICK ACTION CARD
// ============================================================
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 200, 223, 230),
          child: Icon(icon, color: const Color.fromARGB(255, 175, 167, 76)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

// ============================================================
// MY TREES PAGE
// ============================================================
class MyTreesPage extends StatefulWidget {
  const MyTreesPage({super.key});
  @override
  State<MyTreesPage> createState() => _MyTreesPageState();
}

class _MyTreesPageState extends State<MyTreesPage> {
  List<Map<String, dynamic>> trees = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadTrees();
  }

  // ==========================================================
  // LOAD TREES FROM THE SERVER
  // ==========================================================
  Future<void> loadTrees() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await ApiService.getTrees();
      if (!mounted) return;
      setState(() {
        trees = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('My Trees server error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // DELETE TREE
  // ==========================================================
  Future<void> deleteTree(String id) async {
    final deleted = await ApiService.deleteTree(id);
    if (!deleted) {
      throw Exception('The server could not delete this tree.');
    }
    await loadTrees();
  }

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================
  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tree?'),
          content: const Text('Are you sure you want to delete this tree?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteTree(id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color.fromARGB(255, 54, 244, 203)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // BUILD MY TREES
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trees'),
        actions: [
          IconButton(onPressed: loadTrees, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : trees.isEmpty
          ? RefreshIndicator(
              onRefresh: loadTrees,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.park_outlined,
                          size: 80,
                          color: Color.fromARGB(255, 76, 99, 175),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No trees added yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your planted trees will appear here.',
                          style: TextStyle(
                            color: Color.fromARGB(224, 158, 158, 158),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadTrees,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: trees.length,
                itemBuilder: (context, index) {
                  final tree = trees[index];
                  final dynamic photo = tree['photo'];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // PHOTO + DETAILS + DELETE
                          // ==================================================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // PHOTO
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(
                                    255,
                                    232,
                                    242,
                                    245,
                                  ),
                                ),
                                child:
                                    photo != null &&
                                        photo is Uint8List &&
                                        photo.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          photo,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.park,
                                        size: 50,
                                        color: Color.fromARGB(
                                          255,
                                          175,
                                          76,
                                          167,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 15),
                              // DETAILS
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tree['tree_name'] ?? 'Unnamed Tree',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      tree['species'] ?? 'Unknown species',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color.fromARGB(255, 86, 76, 175),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          tree['health_status'] ?? 'Unknown',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // DELETE
                              IconButton(
                                onPressed: () {
                                  final id = tree['id'];
                                  if (id != null) {
                                    confirmDelete(id.toString());
                                  }
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 25),
                          // DATE
                          _TreeInfoRow(
                            icon: Icons.calendar_month,
                            title: 'Planted',
                            value: tree['planted_date'] ?? 'Not available',
                          ),
                          const SizedBox(height: 8),
                          // HEIGHT
                          _TreeInfoRow(
                            icon: Icons.height,
                            title: 'Height',
                            value: tree['height'] != null
                                ? '${tree['height']} m'
                                : 'Not available',
                          ),
                          const SizedBox(height: 8),
                          // LOCATION
                          _TreeInfoRow(
                            icon: Icons.location_on,
                            title: 'Location',
                            value:
                                tree['location_text'] ??
                                'Location not available',
                          ),
                          const SizedBox(height: 8),
                          // GPS
                          if (tree['latitude'] != null &&
                              tree['longitude'] != null)
                            _TreeInfoRow(
                              icon: Icons.gps_fixed,
                              title: 'GPS',
                              value:
                                  '${tree['latitude']}, ${tree['longitude']}',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ============================================================
// TREE INFO ROW
// ============================================================
class _TreeInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _TreeInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 76, 145, 175)),
        const SizedBox(width: 8),
        Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}

// ============================================================
// MAP PAGE
// ============================================================
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();
  List<Map<String, dynamic>> trees = [];
  bool isLoading = true;
  // Default center = India
  final LatLng defaultLocation = const LatLng(20.5937, 78.9629);
  @override
  void initState() {
    super.initState();
    loadMapTrees();
  }

  // ==========================================================
  // LOAD TREE LOCATIONS FROM THE SERVER
  // ==========================================================
  Future<void> loadMapTrees() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await ApiService.getTrees();
      if (!mounted) return;
      setState(() {
        trees = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Map server error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // TREES WITH GPS LOCATION
  // ==========================================================
  List<Map<String, dynamic>> get treesWithLocation {
    return trees.where((tree) {
      return tree['latitude'] != null && tree['longitude'] != null;
    }).toList();
  }

  // ==========================================================
  // MAP CENTER
  // ==========================================================
  LatLng getMapCenter() {
    if (treesWithLocation.isNotEmpty) {
      final tree = treesWithLocation.first;
      return LatLng(
        (tree['latitude'] as num).toDouble(),
        (tree['longitude'] as num).toDouble(),
      );
    }
    return defaultLocation;
  }

  // ==========================================================
  // SHOW TREE DETAILS
  // ==========================================================
  void showTreeDetails(Map<String, dynamic> tree) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ðŸŒ³ Tree Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(
                  tree['tree_name'] ?? 'Unnamed Tree',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 175, 76, 150),
                  ),
                ),
                const SizedBox(height: 10),
                _MapDetailRow(
                  Icons.eco,
                  'Species',
                  tree['species'] ?? 'Unknown',
                ),
                _MapDetailRow(
                  Icons.height,
                  'Height',
                  tree['height'] != null
                      ? '${tree['height']} m'
                      : 'Not available',
                ),
                _MapDetailRow(
                  Icons.favorite,
                  'Health',
                  tree['health_status'] ?? 'Unknown',
                ),
                _MapDetailRow(
                  Icons.calendar_month,
                  'Planted Date',
                  tree['planted_date'] ?? 'Not available',
                ),
                _MapDetailRow(
                  Icons.location_on,
                  'Location',
                  tree['location_text'] ?? 'Location not available',
                ),
                if (tree['latitude'] != null && tree['longitude'] != null)
                  _MapDetailRow(
                    Icons.gps_fixed,
                    'GPS',
                    '${tree['latitude']}, ${tree['longitude']}',
                  ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      if (tree['latitude'] != null &&
                          tree['longitude'] != null) {
                        mapController.move(
                          LatLng(
                            (tree['latitude'] as num).toDouble(),
                            (tree['longitude'] as num).toDouble(),
                          ),
                          17,
                        );
                      }
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('View on Map'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // MAP BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final center = getMapCenter();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantation Map'),
        actions: [
          IconButton(onPressed: loadMapTrees, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // ==================================================
                // OPEN STREET MAP
                // ==================================================
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: treesWithLocation.isNotEmpty ? 15 : 5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.tree_plantation_tracker',
                    ),
                    // ==================================================
                    // TREE MARKERS
                    // ==================================================
                    MarkerLayer(
                      markers: treesWithLocation.map((tree) {
                        final latitude = (tree['latitude'] as num).toDouble();
                        final longitude = (tree['longitude'] as num).toDouble();
                        return Marker(
                          point: LatLng(latitude, longitude),
                          width: 60,
                          height: 60,
                          child: GestureDetector(
                            onTap: () {
                              showTreeDetails(tree);
                            },
                            child: const Icon(
                              Icons.location_on,
                              size: 48,
                              color: Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                // ==================================================
                // TREE COUNT
                // ==================================================
                Positioned(
                  top: 15,
                  left: 15,
                  right: 15,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.park,
                            color: Color.fromARGB(255, 76, 157, 175),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${treesWithLocation.length} tree${treesWithLocation.length == 1 ? '' : 's'} on map',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // ==================================================
                // NO LOCATION MESSAGE
                // ==================================================
                if (treesWithLocation.isEmpty)
                  Center(
                    child: Card(
                      elevation: 5,
                      margin: const EdgeInsets.all(30),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_off,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'No tree locations available',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add a tree with GPS location to see it on the map.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              onPressed: loadMapTrees,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // ==================================================
                // CENTER MAP BUTTON
                // ==================================================
                Positioned(
                  right: 15,
                  bottom: 20,
                  child: FloatingActionButton(
                    heroTag: 'map_location_button',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color.fromARGB(255, 175, 76, 150),
                    onPressed: () {
                      if (treesWithLocation.isNotEmpty) {
                        mapController.move(getMapCenter(), 15);
                      }
                    },
                    child: const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
    );
  }
}

// ============================================================
// MAP DETAIL ROW
// ============================================================
class _MapDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _MapDetailRow(this.icon, this.title, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 175, 76, 122)),
          const SizedBox(width: 10),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE PAGE
// ============================================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ==================================================
          // PROFILE ICON
          // ==================================================
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color.fromARGB(255, 76, 175, 165),
            child: Icon(Icons.person, size: 55, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Tree Plantation User',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 25),
          // ==================================================
          // MY TREES
          // ==================================================
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.park,
                color: Color.fromARGB(255, 76, 104, 175),
              ),
              title: const Text('My Trees'),
              subtitle: const Text('View your planted trees'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final dashboard = context
                    .findAncestorStateOfType<_DashboardScreenState>();
                dashboard?.setState(() {
                  dashboard.currentIndex = 1;
                });
              },
            ),
          ),
          // ==================================================
          // MAP
          // ==================================================
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.map,
                color: Color.fromARGB(255, 76, 160, 175),
              ),
              title: const Text('Plantation Map'),
              subtitle: const Text('View tree locations'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final dashboard = context
                    .findAncestorStateOfType<_DashboardScreenState>();
                dashboard?.setState(() {
                  dashboard.currentIndex = 2;
                });
              },
            ),
          ),
          // ==================================================
          // ABOUT
          // ==================================================
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: Color.fromARGB(255, 76, 137, 175),
              ),
              title: const Text('About'),
              subtitle: const Text('Tree Plantation Tracker'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Tree Plantation Tracker',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.park,
                    color: Color.fromARGB(255, 76, 160, 175),
                    size: 40,
                  ),
                  children: const [
                    Text(
                      'An application for recording and tracking planted trees.',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
