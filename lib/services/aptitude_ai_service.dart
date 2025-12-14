import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../data/predefined_aptitude_test.dart';

/// Service for AI-powered personalized aptitude tests using Google Gemini
class AptitudeAiService {
  // Production backend URL on Render
  static const String baseUrl = 'https://bridgeit-backend.onrender.com';

  /// Get access token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Fetch personalized aptitude questions based on user profile
  Future<List<Map<String, dynamic>>> getPersonalizedQuestions({
    required String educationLevel,
    int questionCount = 10,
  }) async {
    try {
      // Validate education level
      const validLevels = ['10th', '12th', 'Diploma', 'Bachelor', 'Master'];
      if (!validLevels.contains(educationLevel)) {
        throw Exception(
          'Invalid education level: $educationLevel. Valid levels are: ${validLevels.join(", ")}',
        );
      }

      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login first.');
      }

      debugPrint(
        'API Request: GET personalized-questions level=$educationLevel count=$questionCount',
      );

      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/api/aptitude/personalized-questions/?level=$educationLevel&count=$questionCount',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 60), // Increased for AI question generation
            onTimeout: () {
              throw TimeoutException(
                'Request timeout after 60 seconds. The backend is taking longer than expected to generate questions for $educationLevel level. Please try again.',
              );
            },
          );

      debugPrint('API Response Status Code: ${response.statusCode}');
      debugPrint('API Response Body Length: ${response.body.length}');
      debugPrint(
        'API Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonData = json.decode(response.body);
          debugPrint('JSON decoded successfully for $educationLevel level');

          // Extract questions from the response (Gemini backend format)
          final responseData = jsonData['data'];
          if (responseData != null && responseData['questions'] != null) {
            final List<dynamic> questionsData = responseData['questions'];
            debugPrint(
              'Successfully loaded ${questionsData.length} questions for $educationLevel level',
            );
            return questionsData.cast<Map<String, dynamic>>();
          }
          // Fallback for direct questions array
          final List<dynamic> questionsData = jsonData['data'] ?? jsonData;
          debugPrint(
            'Successfully loaded ${questionsData.length} questions for $educationLevel level',
          );
          return questionsData.cast<Map<String, dynamic>>();
        } on FormatException catch (e) {
          debugPrint(
            'FormatException while parsing response for $educationLevel: $e',
          );
          debugPrint('Response body: ${response.body}');
          throw Exception(
            'Invalid JSON response from server for $educationLevel level. Backend may be returning HTML or malformed data. Please contact support.',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 500) {
        debugPrint('500 Server Error for $educationLevel level');
        debugPrint('Response body: ${response.body}');

        // Check if response is HTML (common for 500 errors)
        if (response.body.trim().toLowerCase().startsWith('<html') ||
            response.body.contains('Internal Server Error')) {
          throw Exception(
            'Backend server error for $educationLevel level. The backend may not be configured to handle this education level yet. Please contact support or try another level.',
          );
        }

        // Try to parse JSON error message
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            errorData['error'] ??
                'Failed to generate questions for $educationLevel level. Please try again.',
          );
        } catch (e) {
          debugPrint('Error parsing 500 response: ${response.body}');
          throw Exception(
            'Server error (500) for $educationLevel level. The backend encountered an issue. Please try again later or contact support.',
          );
        }
      } else {
        debugPrint(
          'Unexpected status code ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Failed to fetch questions for $educationLevel level: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: ${e.message}');
      debugPrint('Falling back to predefined questions for $educationLevel');
      return PredefinedAptitudeTest.getQuestions(educationLevel);
    } on SocketException catch (e) {
      debugPrint('SocketException: ${e.message}');
      debugPrint('Falling back to predefined questions for $educationLevel');
      return PredefinedAptitudeTest.getQuestions(educationLevel);
    } catch (e) {
      debugPrint('General Exception: $e');
      debugPrint('Falling back to predefined questions for $educationLevel');
      return PredefinedAptitudeTest.getQuestions(educationLevel);
    }
  }

  /// Analyze aptitude test results with AI (Gemini backend)
  Future<Map<String, dynamic>> analyzeResults({
    required List<Map<String, dynamic>> questions,
    required Map<String, String>
    answers, // Changed to String for answer letters (A, B, C, D)
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login first.');
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/aptitude/analyze-results/'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({'questions': questions, 'answers': answers}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout. Analysis is taking longer than expected.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData['data'] ?? jsonData;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['error'] ?? 'Failed to analyze results. Please try again.',
        );
      } else {
        throw Exception('Failed to analyze results: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Analysis Error: $e');
      debugPrint('Falling back to local analysis');
      return PredefinedAptitudeTest.analyzeResults(questions, answers);
    }
  }

  /// Calculate basic scores from answers (fallback method)
  Map<String, int> calculateScores({
    required List<Map<String, dynamic>> questions,
    required Map<String, int> answers,
  }) {
    int totalScore = 0;
    int section1Score = 0; // Science/STEM
    int section2Score = 0; // Commerce/Business
    int section3Score = 0; // Humanities/Creative

    for (var question in questions) {
      final questionId = question['id'].toString();
      final correctOption = question['correct_option'] as int;
      final section = question['section'] as String;

      if (answers.containsKey(questionId) &&
          answers[questionId] == correctOption) {
        totalScore++;

        if (section == 'Science' || section == 'STEM') {
          section1Score++;
        } else if (section == 'Commerce' || section == 'Business') {
          section2Score++;
        } else if (section == 'Humanities' || section == 'Creative') {
          section3Score++;
        }
      }
    }

    return {
      'total': totalScore,
      'section1': section1Score,
      'section2': section2Score,
      'section3': section3Score,
    };
  }

  /// Convert answer index to letter (0 -> A, 1 -> B, etc.)
  String indexToLetter(int index) {
    return String.fromCharCode(65 + index); // 65 is 'A' in ASCII
  }

  /// Convert answer letter to index (A -> 0, B -> 1, etc.)
  int letterToIndex(String letter) {
    return letter.toUpperCase().codeUnitAt(0) - 65;
  }
}
