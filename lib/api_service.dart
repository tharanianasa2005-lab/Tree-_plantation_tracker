import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'user_session.dart';

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.12:3000',
  );

  // =====================================================
  // REGISTER USER
  // =====================================================

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      print('Register Response: ${response.body}');

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Registration failed',
      };
    } catch (e) {
      print('Register API Error: $e');

      return {'success': false, 'message': 'Unable to connect to server'};
    }
  }

  // =====================================================
  // LOGIN USER
  // =====================================================

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] == true,
        'message': data['message'] ?? 'Login failed',
        'user': data['user'],
        'token': data['token'],
      };
    } catch (e) {
      print('Login API Error: $e');

      return {'success': false, 'message': 'Unable to connect to server'};
    }
  }

  // =====================================================
  // ADD TREE
  // =====================================================

  static Future<bool> addTree({
    required String treeName,
    required String species,
    required double height,
    required String plantationDate,
    required String treeHealth,
    String treePhoto = '',
    String treeLocation = '',
    double? latitude,
    double? longitude,
  }) async {
    if (treePhoto.isNotEmpty && treePhoto.length > 700000) {
      throw Exception(
        'Selected photo is too large for the server. Please choose a smaller image.',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/trees'),
      headers: {..._authorizationHeaders, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'tree_name': treeName,
        'species': species,
        'height': height,
        'planted_date': plantationDate,
        'health_status': treeHealth,
        'location_text': treeLocation,
        'tree_photo': treePhoto,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to save tree: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map || data['success'] != true) {
      throw Exception(
        data is Map
            ? data['message'] ?? 'The server rejected this tree.'
            : 'The server returned an invalid tree response.',
      );
    }

    return true;
  }

  static Future<void> updateTreePhoto({
    required String treeId,
    required Uint8List photoBytes,
  }) async {
    final photo = base64Encode(photoBytes);
    if (photo.length > 700000) {
      throw Exception(
        'Selected photo is too large for the server. Please choose a smaller image.',
      );
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/trees/${Uri.encodeComponent(treeId)}/photo'),
      headers: {..._authorizationHeaders, 'Content-Type': 'application/json'},
      body: jsonEncode({'tree_photo': photo}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update tree photo: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map || data['success'] != true) {
      throw Exception(
        data is Map
            ? data['message'] ?? 'The server rejected this photo.'
            : 'The server returned an invalid photo response.',
      );
    }
  }

  // =====================================================
  // GET ALL TREES
  // =====================================================

  static Future<List<Map<String, dynamic>>> getTrees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/trees'),
      headers: _authorizationHeadersForTreeRequest,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load tree records: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data['success'] == true && data['trees'] is List) {
      final trees = (data['trees'] as List)
          .map((tree) => Map<String, dynamic>.from(tree as Map))
          .toList();

      return _filterTreesForCurrentUser(trees);
    }

    throw Exception('The server returned an invalid tree records response.');
  }

  static List<Map<String, dynamic>> _filterTreesForCurrentUser(
    List<Map<String, dynamic>> trees,
  ) {
    if (UserSession.isAdmin) return trees;

    final currentUserId = UserSession.userId?.trim();
    final currentEmail = UserSession.userEmail.trim().toLowerCase();

    return trees.where((tree) {
      final treeUserId = (tree['user_id'] ?? tree['userId'] ?? tree['owner_id'])
          ?.toString()
          .trim();
      final treeUserEmail =
          (tree['user_email'] ??
                  tree['email'] ??
                  tree['owner_email'] ??
                  tree['created_by_email'])
              ?.toString()
              .trim()
              .toLowerCase();

      final matchesById =
          currentUserId != null &&
          currentUserId.isNotEmpty &&
          treeUserId != null &&
          treeUserId.isNotEmpty &&
          treeUserId == currentUserId;
      final matchesByEmail =
          treeUserEmail != null &&
          treeUserEmail.isNotEmpty &&
          treeUserEmail == currentEmail;

      return matchesById || matchesByEmail;
    }).toList();
  }

  static Future<bool> deleteTree(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/trees/${Uri.encodeComponent(id)}'),
      headers: _authorizationHeaders,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete tree: ${response.statusCode}');
    }

    if (response.statusCode == 204) return true;

    final data = jsonDecode(response.body);
    return data is Map && data['success'] == true;
  }

  // =====================================================
  // GET ALL USERS - ADMIN ONLY
  // =====================================================

  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: _authorizationHeaders,
      );

      print('Get Users Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['users'] ?? [];
        }
      }

      throw Exception('Failed to load users: ${response.statusCode}');
    } catch (e) {
      print('Get Users Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GET REPORTS - ADMIN ONLY
  // =====================================================

  static Future<Map<String, dynamic>> getReports() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reports'),
      headers: _authorizationHeaders,
    );

    print('Reports API Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        return Map<String, dynamic>.from(data['statistics']);
      }
    }

    throw Exception('Failed to load reports: ${response.statusCode}');
  }

  static Map<String, String> get _authorizationHeaders {
    final token = UserSession.token;
    if (token == null || token.isEmpty) {
      throw StateError('Sign in with a server account to access this data.');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Map<String, String> get _authorizationHeadersForTreeRequest {
    return {'Content-Type': 'application/json', ..._authorizationHeaders};
  }
}
