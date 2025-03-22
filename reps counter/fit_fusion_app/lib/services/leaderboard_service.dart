import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_user.dart';
import '../models/workout_challenge.dart';

class LeaderboardService extends ChangeNotifier {
  List<LeaderboardUser> _weeklyUsers = [];
  List<LeaderboardUser> _monthlyUsers = [];
  List<LeaderboardUser> _allTimeUsers = [];
  List<LeaderboardCategory> _categories = [];
  List<WorkoutChallenge> _activeChallenges = [];
  String _currentCategory = 'overall';
  String _currentTimeFrame = 'weekly';
  bool _isLoading = true;

  List<LeaderboardUser> get users {
    switch (_currentTimeFrame) {
      case 'weekly':
        return _weeklyUsers;
      case 'monthly':
        return _monthlyUsers;
      case 'all-time':
        return _allTimeUsers;
      default:
        return _weeklyUsers;
    }
  }

  List<LeaderboardCategory> get categories => _categories;
  List<WorkoutChallenge> get activeChallenges => _activeChallenges;
  String get currentCategory => _currentCategory;
  String get currentTimeFrame => _currentTimeFrame;
  bool get isLoading => _isLoading;

  Future<void> initialize(SharedPreferences prefs) async {
    _isLoading = true;
    notifyListeners();
    
    await _loadCategories();
    await _loadMockData();
    await _loadChallenges();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _categories = [
      LeaderboardCategory(
        id: 'overall',
        name: 'Overall',
        icon: Icons.fitness_center,
        description: 'Combined score from all workout activities',
      ),
      LeaderboardCategory(
        id: 'strength',
        name: 'Strength',
        icon: Icons.fitness_center,
        description: 'Based on weight lifted and strength exercises',
      ),
      LeaderboardCategory(
        id: 'cardio',
        name: 'Cardio',
        icon: Icons.directions_run,
        description: 'Based on distance, time, and calories burned',
      ),
      LeaderboardCategory(
        id: 'consistency',
        name: 'Consistency',
        icon: Icons.calendar_today,
        description: 'Based on workout streaks and attendance',
      ),
    ];
  }

  Future<void> _loadMockData() async {
    // Generate consistent mock data with Indian names
    _weeklyUsers = _generateMockUsers(20, 'weekly');
    _monthlyUsers = _generateMockUsers(20, 'monthly');
    _allTimeUsers = _generateMockUsers(20, 'all-time');
  }

  Future<void> _loadChallenges() async {
    final now = DateTime.now();
    
    _activeChallenges = [
      WorkoutChallenge(
        id: 'challenge_1',
        title: '30-Day Strength Challenge',
        description: 'Complete 30 strength workouts in 30 days',
        pointsReward: 500,
        endDate: now.add(const Duration(days: 20)),
        icon: Icons.fitness_center,
        participantCount: 156,
        completionPercentage: 0.35,
      ),
      WorkoutChallenge(
        id: 'challenge_2',
        title: '10K Steps Daily',
        description: 'Walk 10,000 steps every day for a week',
        pointsReward: 200,
        endDate: now.add(const Duration(days: 5)),
        icon: Icons.directions_walk,
        participantCount: 342,
        completionPercentage: 0.7,
      ),
      WorkoutChallenge(
        id: 'challenge_3',
        title: 'Yoga Master',
        description: 'Complete 15 yoga sessions in a month',
        pointsReward: 300,
        endDate: now.add(const Duration(days: 15)),
        icon: Icons.self_improvement,
        participantCount: 89,
        completionPercentage: 0.5,
      ),
      WorkoutChallenge(
        id: 'challenge_4',
        title: 'Cardio King',
        description: 'Burn 5000 calories through cardio exercises',
        pointsReward: 400,
        endDate: now.add(const Duration(days: 10)),
        icon: Icons.directions_run,
        participantCount: 124,
        completionPercentage: 0.2,
      ),
    ];
  }

  List<LeaderboardUser> _generateMockUsers(int count, String timeFrame) {
    // Fixed list of Indian names in a specific order (no shuffling)
    final List<String> indianNames = [
      'Arjun Sharma', 'Priya Patel', 'Vikram Singh', 'Ananya Desai',
      'Rohan Mehta', 'Neha Gupta', 'Raj Kumar', 'Kavita Reddy',
      'Aditya Joshi', 'Meera Iyer', 'Sanjay Verma', 'Pooja Malhotra',
      'Rahul Kapoor', 'Divya Choudhary', 'Amit Nair', 'Sunita Banerjee',
      'Kiran Rao', 'Deepak Sharma', 'Anjali Mishra', 'Suresh Patel',
      'Nisha Singh', 'Vivek Khanna', 'Ritu Agarwal', 'Manoj Tiwari',
      'Shreya Das', 'Rajesh Kulkarni', 'Shweta Trivedi', 'Nikhil Menon',
      'Aarti Saxena', 'Vijay Chauhan'
    ];

    final List<String> gymLevels = ['Beginner', 'Intermediate', 'Advanced', 'Elite', 'Master'];
    
    final List<String> achievements = [
      'Completed 5 workouts this week!',
      'New personal record: 100kg bench press',
      'Burned 1000 calories in a single workout',
      'Maintained 7-day workout streak',
      'Completed first marathon training',
      'Achieved 10% body fat reduction',
      'Mastered advanced yoga poses',
      'Completed 30-day challenge',
      'Reached 5000 total fitness points',
      'Improved 5k run time by 2 minutes',
    ];

    // Create users with consistent stats
    List<LeaderboardUser> users = [];
    
    // Multiplier for different timeframes
    double pointsMultiplier = timeFrame == 'weekly' ? 1 : (timeFrame == 'monthly' ? 4 : 20);
    
    for (int i = 0; i < count; i++) {
      final name = indianNames[i % indianNames.length];
      
      // Generate consistent stats based on position
      final basePoints = (count - i) * 100 + (timeFrame == 'weekly' ? 0 : 200);
      final points = (basePoints * pointsMultiplier).round();
      final streak = (3 + (count - i) / 4).round();
      final calories = ((count - i) * 100 * pointsMultiplier).round();
      final workouts = ((count - i) / 2 * pointsMultiplier).round();
      
      users.add(
        LeaderboardUser(
          id: 'user_$i',
          name: name,
          avatarUrl: '', // Empty string as we're using local avatars now
          points: points,
          workoutStreak: streak,
          caloriesBurned: calories,
          workoutsCompleted: workouts,
          gymLevel: gymLevels[i % 5],
          isCurrentUser: i == 3, // Make the 4th user the current user
          recentAchievement: i < 5 ? achievements[i] : '',
        ),
      );
    }
    
    return users;
  }

  void setCategory(String categoryId) {
    if (_currentCategory != categoryId) {
      _currentCategory = categoryId;
      notifyListeners();
    }
  }

  void setTimeFrame(String timeFrame) {
    if (_currentTimeFrame != timeFrame) {
      _currentTimeFrame = timeFrame;
      notifyListeners();
    }
  }

  // Method to simulate user interaction - increase points
  void incrementUserPoints(String userId, int additionalPoints) {
    void updateUserInList(List<LeaderboardUser> userList) {
      final index = userList.indexWhere((user) => user.id == userId);
      if (index != -1) {
        final user = userList[index];
        final updatedUser = LeaderboardUser(
          id: user.id,
          name: user.name,
          avatarUrl: user.avatarUrl,
          points: user.points + additionalPoints,
          workoutStreak: user.workoutStreak,
          caloriesBurned: user.caloriesBurned + (additionalPoints ~/ 2),
          workoutsCompleted: user.workoutsCompleted + 1,
          gymLevel: user.gymLevel,
          isCurrentUser: user.isCurrentUser,
          recentAchievement: 'Earned $additionalPoints points!',
        );
        
        userList[index] = updatedUser;
      }
    }
    
    updateUserInList(_weeklyUsers);
    updateUserInList(_monthlyUsers);
    updateUserInList(_allTimeUsers);
    
    // Resort lists by points
    _weeklyUsers.sort((a, b) => b.points.compareTo(a.points));
    _monthlyUsers.sort((a, b) => b.points.compareTo(a.points));
    _allTimeUsers.sort((a, b) => b.points.compareTo(a.points));
    
    notifyListeners();
  }

  // Update challenge progress
  void updateChallengeProgress(String challengeId, double progress) {
    final index = _activeChallenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index != -1) {
      final challenge = _activeChallenges[index];
      final isCompleted = progress >= 1.0;
      
      _activeChallenges[index] = challenge.copyWith(
        completionPercentage: progress,
        isCompleted: isCompleted,
      );
      
      // If challenge is completed, award points to the current user
      if (isCompleted && !challenge.isCompleted) {
        final currentUser = _weeklyUsers.firstWhere(
          (user) => user.isCurrentUser,
          orElse: () => _weeklyUsers.first,
        );
        incrementUserPoints(currentUser.id, challenge.pointsReward);
      }
      
      notifyListeners();
    }
  }

  // Join a challenge
  void joinChallenge(String challengeId) {
    final index = _activeChallenges.indexWhere((challenge) => challenge.id == challengeId);
    if (index != -1) {
      final challenge = _activeChallenges[index];
      _activeChallenges[index] = challenge.copyWith(
        participantCount: challenge.participantCount + 1,
      );
      notifyListeners();
    }
  }
}
