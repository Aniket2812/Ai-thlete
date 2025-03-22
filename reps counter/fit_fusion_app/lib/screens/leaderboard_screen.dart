import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/leaderboard_user.dart';
import '../models/workout_challenge.dart';
import '../services/leaderboard_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_count.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/challenge_card.dart';
import '../widgets/initial_avatar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTopBar = false;
  bool _showChallenges = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.offset > 180 && !_showTopBar) {
      setState(() {
        _showTopBar = true;
      });
    } else if (_scrollController.offset <= 180 && _showTopBar) {
      setState(() {
        _showTopBar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LeaderboardService>(
      builder: (context, leaderboardService, _) {
        if (leaderboardService.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppTheme.accentColor,
            ),
          );
        }
        
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showChallenges = !_showChallenges;
              });
            },
            backgroundColor: AppTheme.accentColor,
            child: Icon(
              _showChallenges ? Icons.leaderboard : Icons.emoji_events,
              color: Colors.black,
            ),
          ),
          body: _showChallenges
              ? _buildChallengesScreen(leaderboardService)
              : _buildLeaderboardScreen(leaderboardService),
        );
      },
    );
  }

  Widget _buildLeaderboardScreen(LeaderboardService leaderboardService) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.backgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: _showTopBar 
                ? const Text(
                    'Leaderboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
              background: Container(
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
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Compete with others and track your progress',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategorySelector(leaderboardService),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.accentColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppTheme.accentColor,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      leaderboardService.setTimeFrame('weekly');
                      break;
                    case 1:
                      leaderboardService.setTimeFrame('monthly');
                      break;
                    case 2:
                      leaderboardService.setTimeFrame('all-time');
                      break;
                    case 3:
                      leaderboardService.setTimeFrame('redeem');
                      break;
                  }
                },
                tabs: const [
                  Tab(text: 'WEEKLY'),
                  Tab(text: 'MONTHLY'),
                  Tab(text: 'ALL TIME'),
                  Tab(text: 'REDEEM'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLeaderboardList(leaderboardService),
          _buildLeaderboardList(leaderboardService),
          _buildLeaderboardList(leaderboardService),
          _buildRedeemList(leaderboardService),
        ],
      ),
    );
  }

  Widget _buildChallengesScreen(LeaderboardService leaderboardService) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.backgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            title: _showTopBar 
              ? null
              : null,
            background: Container(
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
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Challenges',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join challenges to earn extra points',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Active Challenges',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${leaderboardService.activeChallenges.length} available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final challenge = leaderboardService.activeChallenges[index];
              return ChallengeCard(
                challenge: challenge,
                onJoin: () {
                  leaderboardService.joinChallenge(challenge.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You joined ${challenge.title}!'),
                      backgroundColor: AppTheme.accentColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      action: SnackBarAction(
                        label: 'DISMISS',
                        textColor: Colors.black,
                        onPressed: () {},
                      ),
                    ),
                  );
                },
                onProgressUpdate: (progress) {
                  leaderboardService.updateChallengeProgress(challenge.id, progress);
                  
                  if (progress >= 1.0) {
                    // Show confetti and congratulations
                    _showCongratulationsDialog(context, challenge);
                  }
                },
              );
            },
            childCount: leaderboardService.activeChallenges.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80), // Bottom padding for FAB
        ),
      ],
    );
  }
  
  void _showCongratulationsDialog(BuildContext context, WorkoutChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => ConfettiOverlay(
        showConfetti: true,
        child: AlertDialog(
          backgroundColor: AppTheme.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.accentColor,
              width: 2,
            ),
          ),
          title: const Text(
            '🎉 Challenge Completed!',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Icon(
                Icons.emoji_events,
                color: const Color(0xFFFFD700),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations! You completed "${challenge.title}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You earned ${challenge.pointsReward} points!',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _showChallenges = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'VIEW LEADERBOARD',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategorySelector(LeaderboardService leaderboardService) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: leaderboardService.categories.length,
        itemBuilder: (context, index) {
          final category = leaderboardService.categories[index];
          final isSelected = category.id == leaderboardService.currentCategory;
          
          return GestureDetector(
            onTap: () {
              leaderboardService.setCategory(category.id);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppTheme.accentColor 
                  : AppTheme.cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected 
                    ? AppTheme.accentColor 
                    : Colors.grey[800]!,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category.icon,
                    size: 16,
                    color: isSelected ? Colors.black : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaderboardList(LeaderboardService leaderboardService) {
    final users = leaderboardService.users;
    
    if (users.isEmpty) {
      return const Center(
        child: Text(
          'No users found',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    
    // Find the current user's position
    final currentUserIndex = users.indexWhere((user) => user.isCurrentUser);
    
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Top 3 users
        if (users.length >= 3) _buildTopThreeUsers(users.sublist(0, 3)),
        
        // Divider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey[800],
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'RANKINGS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey[800],
                  thickness: 1,
                ),
              ),
            ],
          ),
        ),
        
        // List of users
        ...List.generate(users.length, (index) {
          final user = users[index];
          final isCurrentUser = user.isCurrentUser;
          
          // Highlight the current user's row
          final backgroundColor = isCurrentUser 
            ? AppTheme.accentColor.withOpacity(0.1) 
            : Colors.transparent;
          
          return GestureDetector(
            onTap: () {
              // Simulate earning points when tapping on a user
              leaderboardService.incrementUserPoints(user.id, 10);
              
              // Show confetti for the current user
              if (isCurrentUser) {
                showDialog(
                  context: context,
                  builder: (context) => ConfettiOverlay(
                    showConfetti: true,
                    child: AlertDialog(
                      backgroundColor: AppTheme.cardBackgroundColor,
                      title: const Text(
                        '🎉 Points Added!',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        'You earned 10 points for your workout!',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'CLOSE',
                            style: TextStyle(color: AppTheme.accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Show a snackbar for other users
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('You gave ${user.name} a kudos! (+10 points)'),
                    backgroundColor: AppTheme.accentColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: index < 3 ? _getRankColor(index) : Colors.white,
                      ),
                    ),
                  ),
                  
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrentUser ? AppTheme.accentColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InitialAvatar(
                      name: user.name,
                      size: 40,
                      isCurrentUser: isCurrentUser,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                            if (isCurrentUser)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'YOU',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: Colors.orange[400],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.workoutStreak} day streak',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.gymLevel,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getGymLevelColor(user.gymLevel),
                              ),
                            ),
                          ],
                        ),
                        if (user.recentAchievement.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.recentAchievement,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Points
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedCount(
                        count: user.points,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser ? AppTheme.accentColor : Colors.white,
                        ),
                        suffix: ' pts',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.caloriesBurned} cal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Bottom padding
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTopThreeUsers(List<LeaderboardUser> topUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          _buildTopUserItem(
            topUsers[1],
            2,
            const Color(0xFFC0C0C0),
            size: 90,
            fontSize: 14,
          ),
          
          // First place
          _buildTopUserItem(
            topUsers[0],
            1,
            const Color(0xFFFFD700),
            size: 110,
            fontSize: 16,
            showCrown: true,
          ),
          
          // Third place
          _buildTopUserItem(
            topUsers[2],
            3,
            const Color(0xFFCD7F32),
            size: 80,
            fontSize: 12,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopUserItem(
    LeaderboardUser user,
    int rank,
    Color medalColor, {
    required double size,
    required double fontSize,
    bool showCrown = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCrown) 
            const Icon(
              Icons.emoji_events,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          if (showCrown) 
            const SizedBox(height: 4),
          if (!showCrown) 
            const SizedBox(height: 28),
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: medalColor,
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: InitialAvatar(
                    name: user.name,
                    size: size - 6,
                    backgroundColor: medalColor.withOpacity(0.3),
                    isCurrentUser: user.isCurrentUser,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: medalColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.name.split(' ')[0],
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          AnimatedCount(
            count: user.points,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: medalColor,
            ),
            suffix: ' pts',
          ),
        ],
      ),
    );
  }
  
  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white;
    }
  }
  
  Color _getGymLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.blue;
      case 'Advanced':
        return Colors.purple;
      case 'Elite':
        return Colors.orange;
      case 'Master':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRedeemList(LeaderboardService leaderboardService) {
    return Consumer<ProfileService>(
      builder: (context, profileService, _) {
        final userPoints = profileService.profile.points;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Points display
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: AppTheme.accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        userPoints.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Shopping vouchers
            _buildVoucherSection('Shopping Vouchers', Icons.shopping_bag, [
              _buildVoucherCard(
                'Amazon ₹500 Gift Card',
                'Redeem for a ₹500 Amazon gift card',
                Icons.card_giftcard,
                Colors.orange,
                5000,
                userPoints,
              ),
              _buildVoucherCard(
                'Flipkart ₹500 Gift Card',
                'Redeem for a ₹500 Flipkart gift card',
                Icons.card_giftcard,
                Colors.blue,
                5000,
                userPoints,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Food vouchers
            _buildVoucherSection('Food & Dining Vouchers', Icons.restaurant, [
              _buildVoucherCard(
                'Swiggy ₹200 Voucher',
                'Get ₹200 off on your next Swiggy order',
                Icons.fastfood,
                Colors.orange,
                2000,
                userPoints,
              ),
              _buildVoucherCard(
                'Zomato ₹200 Voucher',
                'Get ₹200 off on your next Zomato order',
                Icons.fastfood,
                Colors.red,
                2000,
                userPoints,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Entertainment vouchers
            _buildVoucherSection('Entertainment Vouchers', Icons.movie, [
              _buildVoucherCard(
                'BookMyShow ₹300 Voucher',
                'Get ₹300 off on movie tickets',
                Icons.movie,
                Colors.red,
                3000,
                userPoints,
              ),
            ]),
            
            const SizedBox(height: 24),
            
            // Fitness vouchers
            _buildVoucherSection('Fitness Vouchers', Icons.fitness_center, [
              _buildVoucherCard(
                'Decathlon ₹300 Voucher',
                'Get ₹300 off on sports equipment',
                Icons.sports_tennis,
                Colors.blue,
                3000,
                userPoints,
              ),
            ]),
          ],
        );
      },
    );
  }
  
  Widget _buildVoucherSection(String title, IconData icon, List<Widget> vouchers) {
    return Column(
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
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...vouchers,
      ],
    );
  }
  
  Widget _buildVoucherCard(
    String title,
    String description,
    IconData icon,
    Color color,
    int pointsCost,
    int userPoints,
  ) {
    final bool canRedeem = userPoints >= pointsCost;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (canRedeem) {
              _showRedeemDialog(title, pointsCost);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Not enough points to redeem this voucher'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars,
                          color: AppTheme.accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pointsCost.toString(),
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: canRedeem
                            ? AppTheme.accentColor
                            : Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        canRedeem ? 'Redeem' : 'Locked',
                        style: TextStyle(
                          color: canRedeem ? Colors.black : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showRedeemDialog(String voucherName, int pointsCost) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Confirm Redemption',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to redeem $voucherName for $pointsCost points?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              // Show success dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully redeemed $voucherName!'),
                  backgroundColor: Colors.green,
                ),
              );
              
              // Update user points in a real app
              // This is just a mock implementation
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _SliverAppBarDelegate(this.tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.backgroundColor,
      child: tabBar,
    );
  }
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
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
