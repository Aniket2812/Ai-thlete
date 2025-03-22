import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RepCounterService {
  // Use the computer's IP address instead of localhost
  static const String baseUrl = 'http://192.168.32.174:5002';
  static String get videoFeedUrl {
    // Add a unique timestamp to the URL to prevent caching
    return '$baseUrl/video_feed';
  }
  bool _isServerRunning = false;
  Timer? _countTimer;

  Future<bool> startServer() async {
    try {
      // This would typically start the Python server
      // In a real app, you might use process_run, flutter_isolate, or platform channels
      // For now, we'll assume the server is started manually
      _isServerRunning = true;
      return true;
    } catch (e) {
      debugPrint('Error starting server: $e');
      return false;
    }
  }

  Future<bool> isServerRunning() async {
    try {
      print('Checking server at URL: $baseUrl');
      final response = await http.get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 5));
      
      print('Server response status: ${response.statusCode}');
      print('Server response headers: ${response.headers}');
      
      _isServerRunning = response.statusCode == 200;
      return _isServerRunning;
    } catch (e) {
      print('Error checking server: $e');
      _isServerRunning = false;
      return false;
    }
  }

  Future<Map<String, dynamic>> startCounting() async {
    if (!_isServerRunning) {
      await isServerRunning();
      if (!_isServerRunning) {
        return {'success': false, 'message': 'Failed to connect to server'};
      }
    }

    try {
      final response = await http.get(Uri.parse('$baseUrl/start_count'))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timeout. Make sure the Python server is running.');
      });
      
      if (response.statusCode == 200) {
        // Start a timer to update the count every second
        _countTimer?.cancel();
        _countTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          getCount();
        });
        
        return {'success': true, 'message': 'Started counting'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error starting count: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> stopCounting() async {
    // Cancel the count timer
    _countTimer?.cancel();
    _countTimer = null;
    
    if (!_isServerRunning) {
      return {'reps': 0};
    }
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/stop_count'))
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Connection timeout. Make sure the Python server is running.');
      });
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'reps': data['count'] ?? 0,
          'left_reps': data['left_reps'] ?? 0,
          'right_reps': data['right_reps'] ?? 0
        };
      } else {
        return {'success': false, 'reps': 0};
      }
    } catch (e) {
      print('Error stopping count: $e');
      return {'success': false, 'reps': 0};
    }
  }

  /// Get the current count
  Future<Map<String, dynamic>> getCount() async {
    if (!_isServerRunning) {
      await isServerRunning();
      if (!_isServerRunning) {
        return {'success': false, 'message': 'Failed to connect to server'};
      }
    }
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'count': data['count'] ?? 0,
          'leftReps': data['left_reps'] ?? 0,
          'rightReps': data['right_reps'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error getting count: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }

  /// Check if the video feed is available
  Future<bool> isVideoFeedAvailable() async {
    final feedUrl = videoFeedUrl;
    try {
      print('Checking video feed at URL: $feedUrl');
      
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ).timeout(const Duration(seconds: 5));
      
      print('Video feed response status: ${response.statusCode}');
      // Only log a portion of the headers to avoid string concatenation errors
      print('Content-Type: ${response.headers['content-type']}');
      print('Response body length: ${response.bodyBytes.length}');
      
      // Consider any image/* content type as valid (not just image/jpeg)
      final isSuccess = response.statusCode == 200;
      final isImage = response.headers['content-type']?.contains('image') == true;
      final hasContent = response.bodyBytes.length > 100; // Ensure we have meaningful content
      
      print('Is success (200): $isSuccess');
      print('Is image content: $isImage');
      print('Has content: $hasContent');
      
      // Accept any response with status 200 and sufficient content
      if (isSuccess && hasContent) {
        print('Video feed is available');
        return true;
      }
      
      print('Video feed is not available');
      return false;
    } catch (e) {
      print('Error checking video feed: $e');
      return false;
    }
  }

  /// Reset the counter
  Future<Map<String, dynamic>> resetCount() async {
    if (!_isServerRunning) {
      await isServerRunning();
      if (!_isServerRunning) {
        return {'success': false, 'message': 'Failed to connect to server'};
      }
    }
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/reset_count'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Count reset',
          'count': data['count'] ?? 0,
          'leftReps': data['left_reps'] ?? 0,
          'rightReps': data['right_reps'] ?? 0,
        };
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('Error resetting count: $e');
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
