import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/resume_analysis_result.dart';

class ResumeApiService {
  // Production backend URL on Render
  static const String baseUrl = 'https://bridgeit-backend.onrender.com';

  /// Get access token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Upload and analyze resume
  Future<ResumeAnalysisResult> uploadResume(File pdfFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login first.');
      }

      var uri = Uri.parse('$baseUrl/api/resume/upload/');
      var request = http.MultipartRequest('POST', uri);

      // Add authorization header (Bearer format for JWT/SimpleJWT)
      request.headers['Authorization'] = 'Bearer $token';

      // Add PDF file
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf_file',
          pdfFile.path,
          filename: pdfFile.path.split(Platform.pathSeparator).last,
        ),
      );

      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Increased timeout for AI processing
        onTimeout: () {
          throw TimeoutException(
            'Request timeout. Resume analysis is taking longer than expected.',
          );
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);

        return ResumeAnalysisResult.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        // Handle bad request
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['error'] ?? 'Invalid request. Only PDF files are allowed.',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 500) {
        // Handle server error
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['error'] ?? 'Failed to process resume. Please try again.';

        // Check if it's a Gemini API configuration error
        if (errorMessage.toLowerCase().contains('gemini') ||
            errorMessage.contains('404') &&
                errorMessage.toLowerCase().contains('model')) {
          throw Exception(
            'AI service is currently unavailable. Please contact support or try again later.',
          );
        }

        throw Exception(errorMessage);
      } else {
        throw Exception('Failed to analyze resume: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (e) {
      throw Exception(e.message ?? 'Request timeout. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      // Re-throw if it's already an Exception, otherwise wrap it
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  /// Get resume analysis history
  Future<List<ResumeHistoryItem>> getResumeHistory() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login first.');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/resume/history/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((item) => ResumeHistoryItem.fromJson(item))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch resume history');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('An error occurred: ${e.toString()}');
    }
  }
}
