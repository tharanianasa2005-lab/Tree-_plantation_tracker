import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'api_service.dart';

class PlantationMapPage extends StatefulWidget {
  const PlantationMapPage({super.key});

  @override
  State<PlantationMapPage> createState() => _PlantationMapPageState();
}

class _PlantationMapPageState extends State<PlantationMapPage> {
  final MapController mapController = MapController();

  List<Map<String, dynamic>> trees = [];
  bool isLoading = true;

  // Default location: India
  final LatLng defaultLocation = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    loadTrees();
  }

  Future<void> loadTrees() async {
    setState(() {
      isLoading = true;
    });

    final data = await ApiService.getTrees();

    if (!mounted) return;

    setState(() {
      trees = data;
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get treesWithLocation {
    return trees.where((tree) {
      return tree['latitude'] != null && tree['longitude'] != null;
    }).toList();
  }

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
                  '🌳 Tree Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                Text(
                  tree['tree_name'] ?? 'Unnamed Tree',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 76, 124, 175),
                  ),
                ),

                const SizedBox(height: 10),

                _detailRow(Icons.eco, 'Species', tree['species'] ?? 'Unknown'),

                _detailRow(
                  Icons.height,
                  'Height',
                  tree['height'] != null
                      ? '${tree['height']} m'
                      : 'Not available',
                ),

                _detailRow(
                  Icons.favorite,
                  'Health',
                  tree['health_status'] ?? 'Unknown',
                ),

                _detailRow(
                  Icons.calendar_month,
                  'Planted Date',
                  tree['planted_date'] ?? 'Not available',
                ),

                _detailRow(
                  Icons.location_on,
                  'Location',
                  tree['location_text'] ?? 'Location not available',
                ),

                if (tree['latitude'] != null && tree['longitude'] != null)
                  _detailRow(
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

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 76, 124, 175)),
          const SizedBox(width: 10),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = getMapCenter();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plantation Map'),
        actions: [
          IconButton(onPressed: loadTrees, icon: const Icon(Icons.refresh)),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
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

                // Tree count
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
                            color: Color.fromARGB(255, 175, 76, 130),
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

                // No location message
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
                              onPressed: loadTrees,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // My location style button
                Positioned(
                  right: 15,
                  bottom: 20,
                  child: FloatingActionButton(
                    heroTag: 'map_location_button',
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 76, 79, 175),
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
