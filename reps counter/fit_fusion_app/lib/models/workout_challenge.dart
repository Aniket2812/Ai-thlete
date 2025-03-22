import 'package:flutter/material.dart';

class WorkoutChallenge {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final DateTime endDate;
  final IconData icon;
  final int participantCount;
  final double completionPercentage;
  final bool isCompleted;

  WorkoutChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.endDate,
    required this.icon,
    required this.participantCount,
    this.completionPercentage = 0.0,
    this.isCompleted = false,
  });

  WorkoutChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsReward,
    DateTime? endDate,
    IconData? icon,
    int? participantCount,
    double? completionPercentage,
    bool? isCompleted,
  }) {
    return WorkoutChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsReward: pointsReward ?? this.pointsReward,
      endDate: endDate ?? this.endDate,
      icon: icon ?? this.icon,
      participantCount: participantCount ?? this.participantCount,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
