import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mess_menu_model.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;

class MessMenuService extends ChangeNotifier {
  MessMenuOfTheWeek? _weeklyMenu;
  bool _isLoading = false;
  String _lastError = '';
  SharedPreferences? _prefs;

  // Path to the common mess menu PDF
  final String _commonPdfPath = 'assets/menu/pdf/mess_menu.pdf';
  String? _localCommonPdfPath;

  MessMenuOfTheWeek? get weeklyMenu => _weeklyMenu;
  bool get isLoading => _isLoading;
  String get lastError => _lastError;
  String? get commonPdfPath => _localCommonPdfPath;

  // Initialize method to load menu data and set up PDFs
  Future<void> initialize(SharedPreferences prefs) async {
    _prefs = prefs;
    await initializeMenus();
  }

  // Default sample menu data
  final Map<String, dynamic> _defaultWeeklyMenu = {
    'menuItems': [
      {
        'day': 'Monday',
        'breakfast': 'Aloo Paratha, Curd, Pickle, Tea',
        'lunch': 'Dal Makhani, Jeera Rice, Roti, Salad',
        'snacks': 'Samosa, Tea',
        'dinner': 'Paneer Butter Masala, Roti, Rice, Raita'
      },
      {
        'day': 'Tuesday',
        'breakfast': 'Poha, Boiled Eggs, Tea, Fruit',
        'lunch': 'Rajma, Rice, Roti, Salad',
        'snacks': 'Bread Pakora, Coffee',
        'dinner': 'Aloo Gobi, Roti, Rice, Salad'
      },
      {
        'day': 'Wednesday',
        'breakfast': 'Paneer Pyaaz Parantha, Butter, Dahi, Hari Mirch Achaar, Chai',
        'lunch': 'Aloo Soyabean, Daal, Boondi Raita, Roti, Rice, Salad',
        'snacks': 'Pav Bhaji, Kate Pyaaz, Chai',
        'dinner': 'Rajma, Aloo Palak, Roti, Rice, Salad, Gulab Jamun'
      },
      {
        'day': 'Thursday',
        'breakfast': 'Idli, Sambhar, Coconut Chutney, Tea',
        'lunch': 'Kadhi Pakora, Rice, Roti, Salad',
        'snacks': 'Fruit Chaat, Lemonade',
        'dinner': 'Mix Vegetable, Roti, Rice, Dal Tadka'
      },
      {
        'day': 'Friday',
        'breakfast': 'Chole Bhature, Pickle, Tea',
        'lunch': 'Paneer Masala, Rice, Roti, Salad',
        'snacks': 'Veg Cutlet, Tea',
        'dinner': 'Dal Fry, Aloo Matar, Roti, Rice, Kheer'
      },
      {
        'day': 'Saturday',
        'breakfast': 'Veg Sandwich, Fruit, Coffee',
        'lunch': 'Chana Masala, Rice, Roti, Raita',
        'snacks': 'Bhelpuri, Cold Drink',
        'dinner': 'Malai Kofta, Roti, Rice, Salad'
      },
      {
        'day': 'Sunday',
        'breakfast': 'Puri Sabji, Halwa, Tea',
        'lunch': 'Biryani, Raita, Salad, Papad',
        'snacks': 'Pastry, Juice',
        'dinner': 'Shahi Paneer, Roti, Rice, Gulab Jamun'
      }
    ]
  };

  // Fixed PDF asset paths for each day (now using a common PDF)
  // Keeping this map for backward compatibility, but all values point to the same file
  final Map<String, String> _pdfAssetPaths = {
    'monday': 'assets/menu/pdf/mess_menu.pdf',
    'tuesday': 'assets/menu/pdf/mess_menu.pdf',
    'wednesday': 'assets/menu/pdf/mess_menu.pdf',
    'thursday': 'assets/menu/pdf/mess_menu.pdf',
    'friday': 'assets/menu/pdf/mess_menu.pdf',
    'saturday': 'assets/menu/pdf/mess_menu.pdf',
    'sunday': 'assets/menu/pdf/mess_menu.pdf',
  };

  // Initialize method to load menu data
  Future<void> initializeMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final menuJson = _prefs?.getString('weekly_menu');

      if (menuJson != null) {
        _weeklyMenu = MessMenuOfTheWeek.fromJson(jsonDecode(menuJson));
      } else {
        // Load default menu
        _weeklyMenu = MessMenuOfTheWeek.fromJson(_defaultWeeklyMenu);
        await _saveMenuData(); // Save default menu
      }
      
      // Load the common PDF
      await _loadCommonPdf();
    } catch (e) {
      _lastError = 'Error loading menu data: $e';
      debugPrint(_lastError);
      // Load default menu on error
      _weeklyMenu = MessMenuOfTheWeek.fromJson(_defaultWeeklyMenu);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveMenuData() async {
    if (_weeklyMenu == null) return;

    try {
      await _prefs?.setString('weekly_menu', jsonEncode(_weeklyMenu!.toJson()));
    } catch (e) {
      _lastError = 'Error saving menu data: $e';
      debugPrint(_lastError);
    }
  }

  // Get menu for today
  MessMenu? getTodayMenu() {
    if (_weeklyMenu == null) return null;
    return _weeklyMenu!.getTodayMenu();
  }

  // Update menu for a specific day
  Future<void> updateDayMenu({
    required String day,
    String? breakfast,
    String? lunch,
    String? snacks,
    String? dinner,
  }) async {
    if (_weeklyMenu == null) return;

    try {
      final dayIndex = _weeklyMenu!.menuItems.indexWhere(
        (menu) => menu.day.toLowerCase() == day.toLowerCase(),
      );

      if (dayIndex >= 0) {
        final updatedMenu = MessMenu(
          day: day,
          breakfast: breakfast ?? _weeklyMenu!.menuItems[dayIndex].breakfast,
          lunch: lunch ?? _weeklyMenu!.menuItems[dayIndex].lunch,
          snacks: snacks ?? _weeklyMenu!.menuItems[dayIndex].snacks,
          dinner: dinner ?? _weeklyMenu!.menuItems[dayIndex].dinner,
          pdfPath: _weeklyMenu!.menuItems[dayIndex].pdfPath,
        );

        _weeklyMenu!.menuItems[dayIndex] = updatedMenu;
        await _saveMenuData();
        notifyListeners();
      }
    } catch (e) {
      _lastError = 'Error updating menu: $e';
      debugPrint(_lastError);
    }
  }

  // Load the common PDF for all days
  Future<void> _loadCommonPdf() async {
    try {
      // Check if the common PDF exists
      final exists = await _assetExists(_commonPdfPath);
      
      if (exists) {
        // Copy the common PDF to local storage
        _localCommonPdfPath = await _copyAssetToLocal(_commonPdfPath, 'common');
        
        // Update all menu items to use the common PDF path
        if (_weeklyMenu != null) {
          for (int i = 0; i < _weeklyMenu!.menuItems.length; i++) {
            final currentMenu = _weeklyMenu!.menuItems[i];
            _weeklyMenu!.menuItems[i] = MessMenu(
              day: currentMenu.day,
              breakfast: currentMenu.breakfast,
              lunch: currentMenu.lunch,
              snacks: currentMenu.snacks,
              dinner: currentMenu.dinner,
              pdfPath: _localCommonPdfPath,
            );
          }
          await _saveMenuData();
        }
      }
    } catch (e) {
      debugPrint('Error loading common PDF: $e');
    }
  }

  // Check if PDF exists in assets and set path
  // This method is kept for backward compatibility
  Future<void> _updateAllPdfPaths() async {
    await _loadCommonPdf();
  }
  
  // Helper to check if an asset exists
  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Helper to copy asset to local storage
  Future<String> _copyAssetToLocal(String assetPath, String day) async {
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'mess_menu_$day.pdf');
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      throw Exception('Failed to copy asset to local: $e');
    }
  }

  // Check if day has PDF
  bool hasPdfForDay(String day) {
    return _localCommonPdfPath != null;
  }
  
  // Get the PDF path for a specific day
  String? getPdfPathForDay(String day) {
    return _localCommonPdfPath;
  }
  
  // Get the common PDF path
  String? getCommonPdfPath() {
    return _localCommonPdfPath;
  }
}
