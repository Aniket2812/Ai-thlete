import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/fitness/v1.dart' as fitness;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// Custom HTTP client that adds the auth token to requests
class GoogleAuthClient extends http.BaseClient {
  final http.Client _client = http.Client();
  final String _token;
  
  GoogleAuthClient(this._token);
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _client.send(request);
  }
  
  @override
  void close() {
    _client.close();
  }
}

class GoogleFitService extends ChangeNotifier {
  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.location.read',
      'https://www.googleapis.com/auth/fitness.body.read',
      'https://www.googleapis.com/auth/fitness.heart_rate.read',
    ],
  );
  
  // Auth client for Google API
  GoogleAuthClient? _authClient;
  http.Client? _httpClient;
  
  // State variables
  bool _isConnected = false;
  String _lastError = '';
  Timer? _dataRefreshTimer;
  Timer? _midnightResetTimer;
  
  // Workout data
  Map<String, dynamic> _workoutData = {
    'steps': 0,
    'calories': 0.0,
    'distance': 0.0,
    'heartRate': 0.0,
  };
  
  // Getters
  bool get isConnected => _isConnected;
  String get lastError => _lastError;
  Map<String, dynamic> get workoutData => _workoutData;
  
  GoogleFitService() {
    _checkPreviousConnection();
  }
  
  // Check if user was previously connected
  Future<void> _checkPreviousConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wasConnected = prefs.getBool('isGoogleFitConnected') ?? false;
      
      if (wasConnected) {
        debugPrint('User was previously connected to Google Fit, attempting to reconnect...');
        connect();
      }
    } catch (e) {
      debugPrint('Error checking previous connection: $e');
    }
  }
  
  // Start auto-refresh timer
  void _startDataRefreshTimer() {
    // Cancel existing timer if any
    _dataRefreshTimer?.cancel();
    
    // Refresh immediately
    refreshWorkoutData();
    
    // Set up a timer to refresh data every 5 minutes
    _dataRefreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      refreshWorkoutData();
    });
    
    // Set up timer to reset data at midnight
    _setupMidnightReset();
  }
  
  // Set up timer to reset data at midnight
  void _setupMidnightReset() {
    // Cancel existing timer if any
    _midnightResetTimer?.cancel();
    
    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);
    
    // Set up one-time timer for midnight reset
    _midnightResetTimer = Timer(timeUntilMidnight, () {
      // Reset data at midnight
      _resetWorkoutData();
      
      // Refresh data immediately after reset
      refreshWorkoutData();
      
      // Set up next midnight reset
      _setupMidnightReset();
    });
  }
  
  // Connect to Google Fit
  Future<bool> connect() async {
    try {
      debugPrint('Connecting to Google Fit...');
      
      // Try to sign in silently first
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      
      // If silent sign-in fails, try interactive sign-in
      if (account == null) {
        account = await _googleSignIn.signIn();
      }
      
      // If sign-in fails, return false
      if (account == null) {
        _lastError = 'Failed to sign in to Google account';
        return false;
      }
      
      // Get authentication
      final auth = await account.authentication;
      
      // Create auth client
      _authClient = GoogleAuthClient(auth.accessToken ?? '');
      
      // Set connected state
      _isConnected = true;
      
      // Immediately refresh workout data
      await refreshWorkoutData();
      
      // Start auto-refresh timer
      _startDataRefreshTimer();
      
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = e.toString();
      debugPrint('Error connecting to Google Fit: $_lastError');
      return false;
    }
  }

  // Disconnect from Google Fit
  Future<void> disconnect() async {
    try {
      // Cancel timers
      _dataRefreshTimer?.cancel();
      _midnightResetTimer?.cancel();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Reset connection state
      _isConnected = false;
      _lastError = '';
      
      // Reset workout data
      _resetWorkoutData();
      
      // Save disconnection state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isGoogleFitConnected', false);
      
      debugPrint('Successfully disconnected from Google Fit');
    } catch (e) {
      _lastError = 'Error disconnecting from Google Fit: ${e.toString()}';
      debugPrint(_lastError);
    }
  }

  // Reset workout data to zeros
  void _resetWorkoutData() {
    _workoutData = {
      'steps': 0,
      'calories': 0.0,
      'distance': 0.0,
      'heartRate': 0.0,
    };
    notifyListeners();
  }

  // Refresh workout data from Google Fit
  Future<void> refreshWorkoutData() async {
    if (!_isConnected || _authClient == null) {
      debugPrint('Cannot refresh data: not connected to Google Fit');
      return;
    }
    
    try {
      debugPrint('Refreshing Google Fit data...');
      
      // Create API client
      final fitnessApi = fitness.FitnessApi(_authClient!);
      
      // Get data for today only
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      // Use nanoseconds for Google Fit API
      final startTimeNanos = startOfDay.millisecondsSinceEpoch * 1000000;
      final endTimeNanos = now.millisecondsSinceEpoch * 1000000;
      
      // Fetch steps using the aggregate endpoint (most accurate)
      final stepsResponse = await fitnessApi.users.dataset.aggregate(
        fitness.AggregateRequest(
          aggregateBy: [
            fitness.AggregateBy(
              dataTypeName: 'com.google.step_count.delta',
              dataSourceId: 'derived:com.google.step_count.delta:com.google.android.gms:estimated_steps',
            ),
          ],
          bucketByTime: fitness.BucketByTime(
            durationMillis: (now.difference(startOfDay).inMilliseconds).toString(),
          ),
          startTimeMillis: startOfDay.millisecondsSinceEpoch.toString(),
          endTimeMillis: now.millisecondsSinceEpoch.toString(),
        ),
        'me',
      );
      
      int totalSteps = 0;
      
      // Extract steps from aggregated data
      if (stepsResponse.bucket != null) {
        for (final bucket in stepsResponse.bucket!) {
          for (final dataset in bucket.dataset ?? []) {
            for (final point in dataset.point ?? []) {
              for (final value in point.value ?? []) {
                if (value.intVal != null) {
                  totalSteps += value.intVal as int;
                }
              }
            }
          }
        }
      }
      
      // Fetch calories using the aggregate endpoint
      final caloriesResponse = await fitnessApi.users.dataset.aggregate(
        fitness.AggregateRequest(
          aggregateBy: [
            fitness.AggregateBy(
              dataTypeName: 'com.google.calories.expended',
              dataSourceId: 'derived:com.google.calories.expended:com.google.android.gms:merge_calories_expended',
            ),
          ],
          bucketByTime: fitness.BucketByTime(
            durationMillis: (now.difference(startOfDay).inMilliseconds).toString(),
          ),
          startTimeMillis: startOfDay.millisecondsSinceEpoch.toString(),
          endTimeMillis: now.millisecondsSinceEpoch.toString(),
        ),
        'me',
      );
      
      double totalCalories = 0.0;
      
      // Extract calories from aggregated data
      if (caloriesResponse.bucket != null) {
        for (final bucket in caloriesResponse.bucket!) {
          for (final dataset in bucket.dataset ?? []) {
            for (final point in dataset.point ?? []) {
              for (final value in point.value ?? []) {
                if (value.fpVal != null) {
                  totalCalories += value.fpVal as double;
                }
              }
            }
          }
        }
      }
      
      // Fetch distance using the aggregate endpoint
      final distanceResponse = await fitnessApi.users.dataset.aggregate(
        fitness.AggregateRequest(
          aggregateBy: [
            fitness.AggregateBy(
              dataTypeName: 'com.google.distance.delta',
              dataSourceId: 'derived:com.google.distance.delta:com.google.android.gms:merge_distance_delta',
            ),
          ],
          bucketByTime: fitness.BucketByTime(
            durationMillis: (now.difference(startOfDay).inMilliseconds).toString(),
          ),
          startTimeMillis: startOfDay.millisecondsSinceEpoch.toString(),
          endTimeMillis: now.millisecondsSinceEpoch.toString(),
        ),
        'me',
      );
      
      double totalDistance = 0.0;
      
      // Extract distance from aggregated data
      if (distanceResponse.bucket != null) {
        for (final bucket in distanceResponse.bucket!) {
          for (final dataset in bucket.dataset ?? []) {
            for (final point in dataset.point ?? []) {
              for (final value in point.value ?? []) {
                if (value.fpVal != null) {
                  totalDistance += value.fpVal as double;
                }
              }
            }
          }
        }
      }
      
      // Get the latest heart rate
      final heartRateDatasetId = '$startTimeNanos-$endTimeNanos';
      final heartRateDataset = await _getDataset(
        fitnessApi, 
        'derived:com.google.heart_rate.bpm:com.google.android.gms:merge_heart_rate_bpm', 
        heartRateDatasetId
      );
      
      double lastHeartRate = 0.0;
      
      if (heartRateDataset != null && heartRateDataset.point != null) {
        // Sort points by end time to get the most recent
        final points = heartRateDataset.point!.toList()
          ..sort((a, b) => 
            (int.parse(b.endTimeNanos ?? '0') - int.parse(a.endTimeNanos ?? '0')));
            
        if (points.isNotEmpty && points.first.value != null && points.first.value!.isNotEmpty) {
          final value = points.first.value!.first;
          if (value.fpVal != null) {
            lastHeartRate = value.fpVal as double;
          }
        }
      }
      
      // Update workout data
      _workoutData = {
        'steps': totalSteps,
        'calories': totalCalories.toStringAsFixed(1),
        'distance': (totalDistance / 1000).toStringAsFixed(2), // Convert to km
        'heartRate': lastHeartRate.toStringAsFixed(0),
      };
      
      debugPrint('Updated workout data: $_workoutData');
      notifyListeners();
      
    } catch (e) {
      debugPrint('Error refreshing Google Fit data: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  // Get dataset from Google Fit API
  Future<fitness.Dataset?> _getDataset(fitness.FitnessApi api, String dataSourceId, String datasetId) async {
    try {
      return await api.users.dataSources.datasets.get('me', dataSourceId, datasetId);
    } catch (e) {
      debugPrint('Error fetching dataset for $dataSourceId: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _dataRefreshTimer?.cancel();
    _midnightResetTimer?.cancel();
    _httpClient?.close();
    super.dispose();
  }
}