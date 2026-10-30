import 'package:flutter/material.dart';
import 'api_service.dart';

class AdminTreesScreen extends StatefulWidget {
  const AdminTreesScreen({super.key});

  @override
  State<AdminTreesScreen> createState() => _AdminTreesScreenState();
}

class _AdminTreesScreenState extends State<AdminTreesScreen> {
  List<dynamic> trees = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTrees();
  }

  Future<void> loadTrees() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getTrees();

      if (!mounted) return;

      setState(() {
        trees = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load tree records: $e';
      });
    }
  }

  String getValue(
    dynamic tree,
    String key, [
    String fallback = 'Not available',
  ]) {
    if (tree is! Map) return fallback;

    final value = tree[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  Widget buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tree Records'),
        backgroundColor: const Color(0xFF3949AB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh records',
            onPressed: loadTrees,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 55,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: loadTrees,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadTrees,
              child: trees.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Icon(Icons.park_outlined, size: 75, color: Colors.grey),
                        SizedBox(height: 15),
                        Center(
                          child: Text(
                            'No online tree records found.',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Pull down to refresh.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          color: const Color(0xFFE8EAF6),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  size: 35,
                                  color: Color(0xFF3949AB),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Total Online Tree Records',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${trees.length}',
                                        style: const TextStyle(
                                          fontSize: 27,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF3949AB),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (int index = 0; index < trees.length; index++)
                          Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        backgroundColor: Color(0xFFE8F5E9),
                                        child: Icon(
                                          Icons.park,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          getValue(
                                            trees[index],
                                            'tree_name',
                                            'Unnamed Tree',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 25),
                                  buildInfo(
                                    'Record ID',
                                    getValue(
                                      trees[index],
                                      'id',
                                      getValue(trees[index], 'tree_id'),
                                    ),
                                  ),
                                  buildInfo(
                                    'Species',
                                    getValue(trees[index], 'species'),
                                  ),
                                  buildInfo(
                                    'Height',
                                    getValue(trees[index], 'height'),
                                  ),
                                  buildInfo(
                                    'Planted Date',
                                    getValue(trees[index], 'planted_date'),
                                  ),
                                  buildInfo(
                                    'Health',
                                    getValue(trees[index], 'health_status'),
                                  ),
                                  buildInfo(
                                    'Location',
                                    getValue(trees[index], 'location_text'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
    );
  }
}
