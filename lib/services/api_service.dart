import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Check if user explicitly wants production backend
  static const bool useProduction = bool.fromEnvironment(
    'USE_PRODUCTION',
    defaultValue: false,
  );

  // Check if running in release mode
  static const bool isRelease = bool.fromEnvironment('dart.vm.product');

  static String get baseUrl {
    // Temporarily using Render.com backend due to emulator networking issues
    // To use local backend, set USE_PRODUCTION=false and fix firewall/networking
    // if (useProduction || isRelease) {
    return 'https://bridgeit-backend.onrender.com/api'; // Production (Render.com)
    // }
    // Local backend running on 0.0.0.0:8000
    // For emulator: use 10.0.2.2 (maps to host machine)
    // For physical device: use 192.168.29.174 (your local IP)
    // return 'http://10.0.2.2:8000/api'; // Local development (emulator)
    // return 'http://192.168.29.174:8000/api'; // Uncomment for physical device
  }

  // Helper to check current environment
  static String get environment {
    if (useProduction) return 'Production (Forced)';
    if (isRelease) return 'Production (Release)';
    return 'Development (Local)';
  }
}

class ApiService {
  // Use environment-based configuration
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<bool> verifyConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(
            const Duration(seconds: 30),
          ); // Increased for Render cold start
      return response.statusCode == 200 ||
          response.statusCode ==
              404; // 404 means server reached but path not found, which is fine for connectivity check
    } catch (e) {
      if (kDebugMode) print('Connection Check Failed: $e');
      return false;
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> _saveAuthData(
    String accessToken,
    String refreshToken,
    int userId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    await prefs.setInt('user_id', userId);
  }

  static Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
  }

  // Register endpoint
  static Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('REGISTER → ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['access'], data['refresh'], data['user_id']);
          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Registration failed',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['error'] ??
                error['message'] ??
                'Registration failed (Status: ${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Registration failed (Status: ${response.statusCode})',
          };
        }
      }
    } on TimeoutException {
      if (kDebugMode) print('Register Timeout Error');
      return {
        'success': false,
        'error': 'Request timeout. Check your connection.',
      };
    } catch (e) {
      if (kDebugMode) print('Register Error: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Student Registration endpoint
  static Future<Map<String, dynamic>> registerStudent(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/student/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'confirm_password': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('STUDENT REGISTER → ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Assuming the response structure is similar to the general register
        // or based on the provided docs: {success, message, access, refresh, user_id}
        if (data['success'] == true) {
          await _saveAuthData(data['access'], data['refresh'], data['user_id']);
          return {'success': true, 'data': data};
        } else {
          // Fallback if success is not explicitly true but 201 returned
          // (The docs say it returns success: true, but just in case)
          await _saveAuthData(data['access'], data['refresh'], data['user_id']);
          return {'success': true, 'data': data};
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['error'] ??
                error['message'] ??
                'Registration failed (Status: ${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Registration failed (Status: ${response.statusCode})',
          };
        }
      }
    } on TimeoutException {
      if (kDebugMode) print('Student Register Timeout Error');
      return {
        'success': false,
        'error': 'Request timeout. Check your connection.',
      };
    } catch (e) {
      if (kDebugMode) print('Student Register Error: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Login endpoint
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 30),
          ); // Increased for Render cold start

      if (kDebugMode) {
        print('LOGIN → ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['access'], data['refresh'], data['user_id']);
          return {'success': true, 'data': data};
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Invalid credentials',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['error'] ??
                error['message'] ??
                'Invalid credentials (Status: ${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Invalid credentials (Status: ${response.statusCode})',
          };
        }
      }
    } on TimeoutException {
      if (kDebugMode) print('Login Timeout Error');
      return {
        'success': false,
        'error': 'Request timeout. Check your connection.',
      };
    } catch (e) {
      if (kDebugMode) print('Login Error: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get current user profile
  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['detail'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Fetch full student profile (including education, stream, etc.)
  static Future<Map<String, dynamic>> fetchStudentProfile() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      print('fetching student profile from: $baseUrl/student/profile/');

      final response = await http.get(
        Uri.parse('$baseUrl/student/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(
        'Student profile response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['detail'] ??
                error['error'] ??
                'Failed to fetch student profile',
          };
        } catch (_) {
          return {
            'success': false,
            'error': 'Failed to fetch student profile (${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('Error fetching student profile: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Setup profile endpoint

  static Future<Map<String, dynamic>> updateStudentProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      print('🔧 Updating profile at: $baseUrl/student/profile/');
      print('📦 Data: $profileData');

      final response = await http
          .patch(
            // Changed from PUT to PATCH
            Uri.parse('$baseUrl/student/profile/'), // Simplified endpoint
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(profileData),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<') ||
          response.body.trim().startsWith('<!')) {
        return {
          'success': false,
          'error':
              'Server error: Endpoint not found or misconfigured (${response.statusCode})',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['error'] ?? error['detail'] ?? 'Profile update failed',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('❌ Exception in updateStudentProfile: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> setupProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      print('🔧 Profile setup endpoint: $baseUrl/student/profile/');
      print('📦 Profile setup data: $profileData');

      // Use PATCH to the same endpoint as profile update
      final response = await http
          .patch(
            Uri.parse('$baseUrl/student/profile/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(profileData),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Profile setup response status: ${response.statusCode}');
      print('📄 Profile setup response body: ${response.body}');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<') ||
          response.body.trim().startsWith('<!')) {
        print('❌ Profile setup returned HTML error page');
        return {
          'success': false,
          'error': 'Server error: Endpoint not found (${response.statusCode})',
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Profile setup successful');
        return {'success': true, 'data': data};
      } else {
        try {
          final error = jsonDecode(response.body);
          print('❌ Profile setup failed: ${error['error'] ?? error['detail']}');
          return {
            'success': false,
            'error':
                error['error'] ?? error['detail'] ?? 'Profile setup failed',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'Profile setup failed (Status: ${response.statusCode})',
          };
        }
      }
    } catch (e) {
      print('❌ Profile setup exception: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Upload resume endpoint
  static Future<Map<String, dynamic>> uploadResume(File resumeFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/resume/upload/'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('pdf_file', resumeFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Resume upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get resume history endpoint
  static Future<Map<String, dynamic>> getResumeHistory() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/resume/history/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch resume history',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get aptitude questions endpoint
  static Future<Map<String, dynamic>> getAptitudeQuestions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/aptitude/questions/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch aptitude questions',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Submit aptitude test endpoint
  static Future<Map<String, dynamic>> submitAptitudeTest(
    Map<String, String> answers,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/aptitude/submit/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'answers': answers}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Aptitude test submission failed',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get aptitude history endpoint
  static Future<Map<String, dynamic>> getAptitudeHistory() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/aptitude/history/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch aptitude history',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // List exams endpoint
  static Future<Map<String, dynamic>> getExams({
    String? level,
    String? stream,
    String? search,
  }) async {
    try {
      final token = await _getToken();
      final queryParams = <String, String>{};

      if (level != null) queryParams['level'] = level;
      if (stream != null) queryParams['stream'] = stream;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '$baseUrl/exams/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch exams',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Save exam endpoint
  static Future<Map<String, dynamic>> saveExam(int examId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/exams/$examId/save/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to save exam',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Unsave exam endpoint
  static Future<Map<String, dynamic>> unsaveExam(int examId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/exams/$examId/unsave/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to unsave exam',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get saved exams endpoint
  static Future<Map<String, dynamic>> getSavedExams() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/exams/saved/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch saved exams',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // List courses endpoint
  static Future<Map<String, dynamic>> getCourses({
    String? level,
    String? stream,
    String? careerPath,
    String? search,
  }) async {
    try {
      final token = await _getToken();
      final queryParams = <String, String>{};

      if (level != null) queryParams['level'] = level;
      if (stream != null) queryParams['stream'] = stream;
      if (careerPath != null) queryParams['career_path'] = careerPath;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '$baseUrl/courses/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch courses',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Save course endpoint
  static Future<Map<String, dynamic>> saveCourse(int courseId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/courses/$courseId/save/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to save course',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Unsave course endpoint
  static Future<Map<String, dynamic>> unsaveCourse(int courseId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/courses/$courseId/unsave/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to unsave course',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get saved courses endpoint
  static Future<Map<String, dynamic>> getSavedCourses() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/courses/saved/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch saved courses',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // List feed posts endpoint
  static Future<Map<String, dynamic>> getFeedPosts({
    String? level,
    String? stream,
    String? search,
    String? authorType,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final queryParams = <String, String>{};

      if (level != null) queryParams['level'] = level;
      if (stream != null) queryParams['stream'] = stream;
      if (search != null) queryParams['search'] = search;
      if (authorType != null) queryParams['author_type'] = authorType;

      final uri = Uri.parse(
        '$baseUrl/feed/posts/',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch feed posts',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Like post endpoint
  static Future<Map<String, dynamic>> likePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/feed/posts/$postId/like/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to like post',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Save post endpoint (TO BE IMPLEMENTED)
  static Future<Map<String, dynamic>> savePost(int postId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/feed/posts/$postId/save/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'post_id': postId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to save post',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Student Dashboard - Unified endpoint for home screen
  static Future<Map<String, dynamic>> getStudentDashboard() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Unauthorized: No token found'};
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/student/dashboard/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('STUDENT_DASHBOARD → ${response.statusCode}');
        print('Dashboard Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        await _clearAuthData();
        return {'success': false, 'error': 'Unauthorized: Token expired'};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                error['error'] ??
                error['message'] ??
                'Failed to fetch dashboard (Status: ${response.statusCode})',
          };
        } catch (e) {
          return {
            'success': false,
            'error':
                'Failed to fetch dashboard (Status: ${response.statusCode})',
          };
        }
      }
    } on TimeoutException {
      if (kDebugMode) print('Student Dashboard Timeout');
      return {
        'success': false,
        'error': 'Request timeout. Check your connection.',
      };
    } catch (e) {
      if (kDebugMode) print('Student Dashboard Error: $e');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<void> logout() async {
    await _clearAuthData();
  }

  // Notification endpoints
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/core/notifications/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to fetch notifications',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/core/notifications/$notificationId/mark-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to mark notification as read',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/core/notifications/mark-all-read/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'error': error['error'] ?? 'Failed to mark all notifications as read',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }
}
