import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileService extends ChangeNotifier {
  Profile _profile = Profile.sample();
  
  Profile get profile => _profile;
  
  // Initialize method to load saved profile data
  Future<void> initialize(SharedPreferences prefs) async {
    try {
      final savedProfileJson = prefs.getString('user_profile');
      if (savedProfileJson != null) {
        final profileData = json.decode(savedProfileJson);
        _profile = Profile.fromJson(profileData);
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Use sample profile as fallback
      _profile = Profile.sample();
    }
  }
  
  // Save profile to SharedPreferences
  Future<void> _saveProfile(SharedPreferences prefs) async {
    try {
      final profileJson = json.encode(_profile.toJson());
      await prefs.setString('user_profile', profileJson);
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    double? height,
    double? weight,
    String? avatarUrl,
    String? fitnessGoal,
    Map<String, bool>? healthConditions,
    int? points,
  }) async {
    // Calculate BMI if height and weight are provided
    double? newBmi;
    if (height != null && weight != null) {
      // BMI formula: weight (kg) / (height (m))²
      final heightInMeters = height / 100;
      newBmi = weight / (heightInMeters * heightInMeters);
    } else if (weight != null) {
      // Recalculate with existing height
      final heightInMeters = _profile.height / 100;
      newBmi = weight / (heightInMeters * heightInMeters);
    } else if (height != null) {
      // Recalculate with existing weight
      final heightInMeters = height / 100;
      newBmi = _profile.weight / (heightInMeters * heightInMeters);
    }
    
    _profile = _profile.copyWith(
      name: name,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      age: age,
      height: height,
      weight: weight,
      bmi: newBmi,
      avatarUrl: avatarUrl,
      fitnessGoal: fitnessGoal,
      healthConditions: healthConditions,
      points: points,
    );
    
    notifyListeners();
    
    // Save the updated profile
    final prefs = await SharedPreferences.getInstance();
    await _saveProfile(prefs);
  }
  
  Future<void> incrementWorkoutsCompleted() async {
    final newCount = _profile.workoutsCompleted + 1;
    final updatedProfile = _profile.copyWith(workoutsCompleted: newCount);
    _profile = updatedProfile;
    notifyListeners();
    
    // Save the updated profile
    final prefs = await SharedPreferences.getInstance();
    await _saveProfile(prefs);
  }
  
  Future<void> updateWorkoutStreak({required bool didWorkoutToday}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // If last workout was yesterday, increment streak
    if (didWorkoutToday) {
      if (_profile.lastWorkoutDate == null) {
        // First workout
        _profile = _profile.copyWith(
          workoutStreak: 1,
          lastWorkoutDate: today,
        );
      } else {
        final lastWorkout = _profile.lastWorkoutDate!;
        final lastWorkoutDay = DateTime(lastWorkout.year, lastWorkout.month, lastWorkout.day);
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        
        if (lastWorkoutDay.isAtSameMomentAs(yesterday)) {
          // Consecutive day, increment streak
          _profile = _profile.copyWith(
            workoutStreak: _profile.workoutStreak + 1,
            lastWorkoutDate: today,
          );
        } else if (lastWorkoutDay.isBefore(yesterday)) {
          // Missed a day, reset streak
          _profile = _profile.copyWith(
            workoutStreak: 1,
            lastWorkoutDate: today,
          );
        } else if (!lastWorkoutDay.isAtSameMomentAs(today)) {
          // Update last workout date if it's not already today
          _profile = _profile.copyWith(lastWorkoutDate: today);
        }
      }
      
      notifyListeners();
      
      // Save the updated profile
      final prefs = await SharedPreferences.getInstance();
      await _saveProfile(prefs);
    }
  }
  
  Future<void> toggleHealthCondition(String condition) async {
    final currentConditions = Map<String, bool>.from(_profile.healthConditions ?? {});
    currentConditions[condition] = !(currentConditions[condition] ?? false);
    
    _profile = _profile.copyWith(healthConditions: currentConditions);
    notifyListeners();
    
    // Save the updated profile
    final prefs = await SharedPreferences.getInstance();
    await _saveProfile(prefs);
  }
  
  // Add points to the user's profile
  Future<void> addPoints(int pointsToAdd) async {
    final newPoints = _profile.points + pointsToAdd;
    await updateProfile(points: newPoints);
  }
  
  // Deduct points from the user's profile
  Future<bool> deductPoints(int pointsToDeduct) async {
    if (_profile.points < pointsToDeduct) {
      return false; // Not enough points
    }
    
    final newPoints = _profile.points - pointsToDeduct;
    await updateProfile(points: newPoints);
    return true;
  }
}
