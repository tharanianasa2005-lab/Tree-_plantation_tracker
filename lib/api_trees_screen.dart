import 'package:flutter/material.dart';
import 'api_service.dart';

class ApiTreesScreen extends StatefulWidget {
  const ApiTreesScreen({super.key});

  @override
  State<ApiTreesScreen> createState() => _ApiTreesScreenState();
}

class _ApiTreesScreenState extends State<ApiTreesScreen> {
  late Future<List<dynamic>> treesFuture;

  @override
  void initState() {
    super.initState();
    treesFuture = ApiService.getTrees();
  }

  void refreshTrees() {
    setState(() {
      treesFuture = ApiService.getTrees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Tree Records'),
        actions: [
          IconButton(
            onPressed: refreshTrees,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: treesFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 15),
                  Text(
                    'Fetching tree data from REST API...',
                  ),
                ],
              ),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Unable to fetch tree data',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: refreshTrees,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final trees = snapshot.data ?? [];

          // No data
          if (trees.isEmpty) {
            return const Center(
              child: Text(
                'No tree records found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // Display API data
          return RefreshIndicator(
            onRefresh: () async {
              refreshTrees();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: trees.length,
              itemBuilder: (context, index) {
                final tree = trees[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              child: Text(
                                '${index + 1}',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                tree['tree_name']
                                        ?.toString() ??
                                    'Unnamed Tree',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Text(
                          'Species: ${tree['species'] ?? 'Not available'}',
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Height: ${tree['height'] ?? 'Not available'}',
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Health: ${tree['health_status'] ?? 'Not available'}',
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Location: ${tree['location_text'] ?? 'Not available'}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}