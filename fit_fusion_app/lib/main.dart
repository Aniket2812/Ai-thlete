import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/community_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/diet_planner_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'services/google_fit_service.dart';
import 'services/community_service.dart';
import 'services/profile_service.dart';
import 'services/mess_menu_service.dart';
import 'services/leaderboard_service.dart';
import 'services/redemption_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services that need SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final profileService = ProfileService();
  await profileService.initialize(prefs);
  
  final messMenuService = MessMenuService();
  await messMenuService.initialize(prefs);
  
  final communityService = CommunityService();
  
  final leaderboardService = LeaderboardService();
  await leaderboardService.initialize(prefs);
  
  final redemptionService = RedemptionService(profileService);
  await redemptionService.initialize();
  
  runApp(MyApp(
    profileService: profileService,
    communityService: communityService,
    messMenuService: messMenuService,
    leaderboardService: leaderboardService,
    redemptionService: redemptionService,
  ));
}

class MyApp extends StatelessWidget {
  final ProfileService profileService;
  final CommunityService communityService;
  final MessMenuService messMenuService;
  final LeaderboardService leaderboardService;
  final RedemptionService redemptionService;

  const MyApp({
    Key? key,
    required this.profileService,
    required this.communityService,
    required this.messMenuService,
    required this.leaderboardService,
    required this.redemptionService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final googleFitService = GoogleFitService();
          return googleFitService;
        }),
        ChangeNotifierProvider.value(value: communityService),
        ChangeNotifierProvider.value(value: profileService),
        ChangeNotifierProvider.value(value: messMenuService),
        ChangeNotifierProvider.value(value: leaderboardService),
        ChangeNotifierProvider.value(value: redemptionService),
      ],
      child: MaterialApp(
        title: 'Ai-thlete',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppTheme.backgroundColor,
          colorScheme: ColorScheme.dark(
            primary: AppTheme.accentColor,
            secondary: AppTheme.accentColor,
            background: AppTheme.backgroundColor,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/', // Start with splash screen
        routes: {
          '/': (context) => const SplashScreen(), // Splash screen as initial route
          '/home': (context) => const MainScreen(), // Main screen route
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CommunityScreen(),
    const DietPlannerScreen(),
    const LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main screen content
          _screens[_selectedIndex],
          
          // Profile button that appears only on the home screen
          if (_selectedIndex == 0) // Only show on home screen (index 0)
            Positioned(
              top: 45, // Positioned below status bar
              right: 16,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 18,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppTheme.accentColor.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.cardBackgroundColor,
          selectedItemColor: AppTheme.accentColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people, size: 24),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu, size: 24),
              label: 'Diet Planner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard, size: 24),
              label: 'Leaderboard',
            ),
          ],
        ),
      ),
    );
  }
}