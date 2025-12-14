import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login first.');
      }

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
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout. Question generation is taking longer than expected.',
              );
            },
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        // Extract questions from the response (Gemini backend format)
        final responseData = jsonData['data'];
        if (responseData != null && responseData['questions'] != null) {
          final List<dynamic> questionsData = responseData['questions'];
          return questionsData.cast<Map<String, dynamic>>();
        }
        // Fallback for direct questions array
        final List<dynamic> questionsData = jsonData['data'] ?? jsonData;
        return questionsData.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 500) {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['error'] ??
              'Failed to generate questions. Please try again.',
        );
      } else {
        throw Exception('Failed to fetch questions: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      throw Exception(e.message ?? 'Request timeout. Please try again.');
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An error occurred: ${e.toString()}');
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
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      throw Exception(e.message ?? 'Request timeout. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An error occurred: ${e.toString()}');
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
