import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/mess_menu_service.dart';
import '../models/profile_model.dart';
import '../models/mess_menu_model.dart';
import '../theme/app_theme.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class DietPlannerScreen extends StatelessWidget {
  const DietPlannerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer2<ProfileService, MessMenuService>(
        builder: (context, profileService, messMenuService, _) {
          final profile = profileService.profile;
          final todayMenu = messMenuService.getTodayMenu();
          return Column(
            children: [
              // App Bar with centered heading
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.accentColor.withOpacity(0.3),
                      AppTheme.backgroundColor,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(top: 40, bottom: 16),
                child: Center(
                  child: const Text(
                    'Diet Planner',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: _buildDietPlanContent(context, profile, todayMenu, messMenuService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDietPlanContent(
    BuildContext context, 
    Profile profile, 
    MessMenu? todayMenu,
    MessMenuService messMenuService
  ) {
    // Calculate calorie needs based on profile metrics
    final bmr = _calculateBMR(profile);
    final dailyCalories = _calculateDailyCalories(bmr, profile);
    final carbsGrams = (dailyCalories * 0.5 / 4).round(); // 50% carbs, 4 cal/g
    final proteinGrams = (dailyCalories * 0.25 / 4).round(); // 25% protein, 4 cal/g
    final fatGrams = (dailyCalories * 0.25 / 9).round(); // 25% fat, 9 cal/g
    
    // Calculate recommended chapati count
    final recommendedChapatis = _calculateRecommendedChapatis(profile, dailyCalories);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDietSummaryCard(dailyCalories, carbsGrams, proteinGrams, fatGrams),
        const SizedBox(height: 16),
        _buildTodaysMealPlanCard(todayMenu, recommendedChapatis, messMenuService, context),
        const SizedBox(height: 16),
        _buildAdditionalRecommendationsCard(profile),
        const SizedBox(height: 16),
        _buildNutritionTipsCard(),
      ],
    );
  }

  Widget _buildDietSummaryCard(int dailyCalories, int carbsGrams, int proteinGrams, int fatGrams) {
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Diet Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildNutrientRow('Daily Calories', '$dailyCalories kcal', Icons.local_fire_department),
            const Divider(color: Color(0xFF2A2A2A)),
            _buildNutrientRow('Carbohydrates', '$carbsGrams g', Icons.grain),
            const Divider(color: Color(0xFF2A2A2A)),
            _buildNutrientRow('Protein', '$proteinGrams g', Icons.fitness_center),
            const Divider(color: Color(0xFF2A2A2A)),
            _buildNutrientRow('Fat', '$fatGrams g', Icons.opacity),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysMealPlanCard(
    MessMenu? todayMenu, 
    int recommendedChapatis,
    MessMenuService messMenuService,
    BuildContext context
  ) {
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final today = dayNames[now.weekday - 1]; // weekday is 1-7, where 1 is Monday
    
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lunch_dining,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Today\'s Mess Menu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
                const Spacer(),
                // Today's date indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.accentColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    today,
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Show textual menu details
            if (todayMenu != null)
              Column(
                children: [
                  _buildMealCard(
                    'Breakfast',
                    todayMenu.breakfast,
                    'Recommended: 2 servings, 1 cup milk/tea',
                    Icons.free_breakfast,
                  ),
                  const SizedBox(height: 12),
                  _buildMealCard(
                    'Lunch',
                    todayMenu.lunch,
                    'Recommended: $recommendedChapatis rotis, 1 cup vegetables, 1 cup salad',
                    Icons.restaurant,
                  ),
                  const SizedBox(height: 12),
                  _buildMealCard(
                    'Snacks',
                    todayMenu.snacks,
                    'Recommended: 1 serving, 1 cup tea/coffee',
                    Icons.cake,
                  ),
                  const SizedBox(height: 12),
                  _buildMealCard(
                    'Dinner',
                    todayMenu.dinner,
                    'Recommended: ${recommendedChapatis-1} rotis, 1 cup vegetables, 1/2 cup rice',
                    Icons.dinner_dining,
                  ),
                ],
              )
            else
              const Center(
                child: Text(
                  'No menu available for today. Use the settings button to manage menus.',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const SizedBox(height: 16),
            
            Center(
              child: Text(
                'The mess menu is displayed according to the current day of the week.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalRecommendationsCard(Profile profile) {
    // Additional recommendations based on profile
    final List<String> recommendations = [];
    
    // Add recommendations based on user's health metrics
    if (profile.bmi > 25) {
      recommendations.add('Add a protein shake (without sugar) after workouts');
      recommendations.add('Include a bowl of green leafy vegetables before meals');
      recommendations.add('Replace rice with additional salad at dinner');
    } else if (profile.bmi < 18.5) {
      recommendations.add('Add a protein shake with banana and peanut butter');
      recommendations.add('Include dry fruits and nuts as mid-meal snacks');
      recommendations.add('Add an extra glass of milk before bedtime');
    } else {
      recommendations.add('Include 1-2 fruits between meals');
      recommendations.add('Add a handful of mixed nuts as a mid-morning snack');
      recommendations.add('Include a protein shake post-workout');
    }
    
    // Add additional recommendations based on fitness goal
    if (profile.fitnessGoal.toLowerCase().contains('muscle')) {
      recommendations.add('Include eggs or paneer for breakfast');
      recommendations.add('Add 1 scoop of whey protein after workouts');
      recommendations.add('Increase protein intake at dinner with additional chicken/paneer/tofu');
    } else if (profile.fitnessGoal.toLowerCase().contains('weight loss')) {
      recommendations.add('Start meals with a bowl of vegetable soup');
      recommendations.add('Replace rice with extra vegetables');
      recommendations.add('Have herbal tea instead of regular tea');
    }
    
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Additional Recommendations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var recommendation in recommendations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionTipsCard() {
    final tips = [
      'Drink at least 3-4 liters of water throughout the day',
      'Have meals at regular intervals to maintain blood sugar levels',
      'Include a variety of colorful fruits and vegetables for diverse nutrients',
      'Limit processed foods and added sugars',
      'Consider taking vitamin D and calcium supplements if you have limited sun exposure'
    ];
    
    return Card(
      color: AppTheme.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nutrition Tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (var tip in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String mealType, String mealItems, String recommendations, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mealItems,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF2A2A2A),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.recommend,
                  color: AppTheme.accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendations,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            nutrient,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
        ],
      ),
    );
  }

  // Calculate Basal Metabolic Rate using the Harris-Benedict equation
  double _calculateBMR(Profile profile) {
    if (profile.gender.toLowerCase() == 'male') {
      return 88.362 + (13.397 * profile.weight) + (4.799 * profile.height) - (5.677 * profile.age);
    } else {
      return 447.593 + (9.247 * profile.weight) + (3.098 * profile.height) - (4.330 * profile.age);
    }
  }

  // Calculate daily calories based on activity level and fitness goal
  int _calculateDailyCalories(double bmr, Profile profile) {
    // Assume moderate activity level (1.55) for most users
    double activityFactor = 1.55;
    
    // Adjust calories based on fitness goal
    double goalAdjustment = 0;
    if (profile.fitnessGoal.toLowerCase().contains('weight loss')) {
      goalAdjustment = -300; // Caloric deficit for weight loss
    } else if (profile.fitnessGoal.toLowerCase().contains('muscle') || 
               profile.fitnessGoal.toLowerCase().contains('gain')) {
      goalAdjustment = 300; // Caloric surplus for muscle gain
    }
    
    return (bmr * activityFactor + goalAdjustment).round();
  }

  // Calculate recommended number of chapatis based on calorie needs and profile
  int _calculateRecommendedChapatis(Profile profile, int dailyCalories) {
    // Base chapati recommendation on calories and gender
    int baseChapatis;
    
    if (profile.gender.toLowerCase() == 'male') {
      if (dailyCalories > 2500) {
        baseChapatis = 4;
      } else if (dailyCalories > 2000) {
        baseChapatis = 3;
      } else {
        baseChapatis = 2;
      }
    } else {
      if (dailyCalories > 2000) {
        baseChapatis = 3;
      } else if (dailyCalories > 1500) {
        baseChapatis = 2;
      } else {
        baseChapatis = 1;
      }
    }
    
    // Adjust based on fitness goal
    if (profile.fitnessGoal.toLowerCase().contains('weight loss')) {
      baseChapatis = (baseChapatis * 0.7).round(); // Reduce for weight loss
      if (baseChapatis < 1) baseChapatis = 1; // Minimum 1 chapati
    } else if (profile.fitnessGoal.toLowerCase().contains('muscle')) {
      baseChapatis = (baseChapatis * 1.3).round(); // Increase for muscle gain
    }
    
    return baseChapatis;
  }

  void _showMenuSettingsDialog(BuildContext context) {
    final messMenuService = Provider.of<MessMenuService>(context, listen: false);
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: const Text(
          'Mess Menu Settings',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'View and edit weekly mess menus',
                style: TextStyle(color: AppTheme.secondaryTextColor),
              ),
              const SizedBox(height: 16),
              
              const Divider(color: Color(0xFF2A2A2A)),
              const SizedBox(height: 8),
              
              ...dayNames.map((day) {
                return Card(
                  color: AppTheme.backgroundColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit, 
                                size: 16,
                                color: AppTheme.accentColor,
                              ),
                              tooltip: 'Edit text menu',
                              onPressed: () {
                                _showEditMenuDialog(context, messMenuService, day);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Text(
                'Note: The mess menu is displayed according to the current day of the week.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextColor.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, MessMenuService messMenuService, String day) {
    final menu = messMenuService.weeklyMenu?.getMenuForDay(day);
    
    final breakfastController = TextEditingController(text: menu?.breakfast ?? '');
    final lunchController = TextEditingController(text: menu?.lunch ?? '');
    final snacksController = TextEditingController(text: menu?.snacks ?? '');
    final dinnerController = TextEditingController(text: menu?.dinner ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackgroundColor,
        title: Text(
          'Edit $day Menu',
          style: const TextStyle(color: AppTheme.textColor),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Breakfast',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: breakfastController,
                  style: const TextStyle(color: AppTheme.textColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Lunch',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: lunchController,
                  style: const TextStyle(color: AppTheme.textColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Snacks',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: snacksController,
                  style: const TextStyle(color: AppTheme.textColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Dinner',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: dinnerController,
                  style: const TextStyle(color: AppTheme.textColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
            onPressed: () async {
              await messMenuService.updateDayMenu(
                day: day,
                breakfast: breakfastController.text,
                lunch: lunchController.text,
                snacks: snacksController.text,
                dinner: dinnerController.text,
              );
              
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close settings dialog too
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Menu updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
