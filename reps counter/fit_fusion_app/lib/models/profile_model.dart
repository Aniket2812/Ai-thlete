class Profile {
  final String name;
  final String email;
  final String gender;
  final DateTime dateOfBirth;
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final double bmi;
  final Map<String, bool> healthConditions;
  final String avatarUrl;
  final String fitnessGoal;
  final int workoutsCompleted;
  final int streakDays;
  final int workoutStreak;
  final DateTime? lastWorkoutDate;
  final int points;

  Profile({
    required this.name,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.age,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.healthConditions,
    required this.avatarUrl,
    required this.fitnessGoal,
    required this.workoutsCompleted,
    required this.streakDays,
    this.workoutStreak = 0,
    this.lastWorkoutDate,
    required this.points,
  });

  // Convert Profile to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'age': age,
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'healthConditions': healthConditions,
      'avatarUrl': avatarUrl,
      'fitnessGoal': fitnessGoal,
      'workoutsCompleted': workoutsCompleted,
      'streakDays': streakDays,
      'workoutStreak': workoutStreak,
      'lastWorkoutDate': lastWorkoutDate?.toIso8601String(),
      'points': points,
    };
  }
  
  // Create Profile from JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'] as String,
      email: json['email'] as String,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      healthConditions: Map<String, bool>.from(json['healthConditions'] as Map),
      avatarUrl: json['avatarUrl'] as String,
      fitnessGoal: json['fitnessGoal'] as String,
      workoutsCompleted: json['workoutsCompleted'] as int,
      streakDays: json['streakDays'] as int,
      workoutStreak: json['workoutStreak'] as int,
      lastWorkoutDate: json['lastWorkoutDate'] != null ? DateTime.parse(json['lastWorkoutDate'] as String) : null,
      points: json['points'] as int,
    );
  }

  // Convenience constructor with sample data
  factory Profile.sample() {
    return Profile(
      name: "Raj Sharma",
      email: "raj.sharma@gmail.com",
      gender: "Male",
      dateOfBirth: DateTime(1998, 6, 15),
      age: 27,
      height: 175,
      weight: 70,
      bmi: 22.9,
      healthConditions: {
        "Diabetes": false,
        "Hypertension": false,
        "Asthma": true,
        "Heart Disease": false,
        "Thyroid": false,
      },
      avatarUrl: "https://randomuser.me/api/portraits/men/32.jpg",
      fitnessGoal: "Build muscle and improve endurance",
      workoutsCompleted: 47,
      streakDays: 12,
      workoutStreak: 0,
      points: 100,
    );
  }

  // Create a copy with modified values
  Profile copyWith({
    String? name,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    int? age,
    double? height,
    double? weight,
    double? bmi,
    Map<String, bool>? healthConditions,
    String? avatarUrl,
    String? fitnessGoal,
    int? workoutsCompleted,
    int? streakDays,
    int? workoutStreak,
    DateTime? lastWorkoutDate,
    int? points,
  }) {
    return Profile(
      name: name ?? this.name,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      healthConditions: healthConditions ?? this.healthConditions,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      workoutsCompleted: workoutsCompleted ?? this.workoutsCompleted,
      streakDays: streakDays ?? this.streakDays,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      points: points ?? this.points,
    );
  }
}
