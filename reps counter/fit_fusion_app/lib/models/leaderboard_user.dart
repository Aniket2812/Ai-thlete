import 'package:flutter/material.dart';

class LeaderboardUser {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;
  final int workoutStreak;
  final int caloriesBurned;
  final int workoutsCompleted;
  final String gymLevel;
  final bool isCurrentUser;
  final String recentAchievement;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.workoutStreak,
    required this.caloriesBurned,
    required this.workoutsCompleted,
    required this.gymLevel,
    this.isCurrentUser = false,
    this.recentAchievement = '',
  });
}

class LeaderboardCategory {
  final String id;
  final String name;
  final IconData icon;
  final String description;

  LeaderboardCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
