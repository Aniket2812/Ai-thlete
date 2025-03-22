import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/redemption_voucher.dart';
import '../services/profile_service.dart';

class RedemptionService extends ChangeNotifier {
  final List<VoucherCategory> _categories = [];
  final List<RedemptionVoucher> _availableVouchers = [];
  final List<String> _redeemedVoucherIds = [];
  final ProfileService _profileService;
  
  RedemptionService(this._profileService);
  
  List<VoucherCategory> get categories => _categories;
  List<RedemptionVoucher> get availableVouchers => _availableVouchers;
  List<String> get redeemedVoucherIds => _redeemedVoucherIds;
  
  Future<void> initialize() async {
    await _loadCategories();
    await _loadVouchers();
    await _loadRedeemedVouchers();
  }
  
  Future<void> _loadCategories() async {
    _categories.clear();
    _categories.addAll([
      VoucherCategory(
        id: 'shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag,
      ),
      VoucherCategory(
        id: 'food',
        name: 'Food & Dining',
        icon: Icons.restaurant,
      ),
      VoucherCategory(
        id: 'entertainment',
        name: 'Entertainment',
        icon: Icons.movie,
      ),
      VoucherCategory(
        id: 'fitness',
        name: 'Fitness',
        icon: Icons.fitness_center,
      ),
    ]);
  }
  
  Future<void> _loadVouchers() async {
    _availableVouchers.clear();
    _availableVouchers.addAll([
      RedemptionVoucher(
        id: 'amazon_500',
        name: 'Amazon ₹500 Gift Card',
        description: 'Redeem for a ₹500 Amazon gift card',
        pointsCost: 5000,
        imageUrl: 'assets/images/amazon_logo.png',
        icon: Icons.card_giftcard,
        color: Colors.orange,
        category: 'shopping',
      ),
      RedemptionVoucher(
        id: 'flipkart_500',
        name: 'Flipkart ₹500 Gift Card',
        description: 'Redeem for a ₹500 Flipkart gift card',
        pointsCost: 5000,
        imageUrl: 'assets/images/flipkart_logo.png',
        icon: Icons.card_giftcard,
        color: Colors.blue,
        category: 'shopping',
      ),
      RedemptionVoucher(
        id: 'swiggy_200',
        name: 'Swiggy ₹200 Voucher',
        description: 'Get ₹200 off on your next Swiggy order',
        pointsCost: 2000,
        imageUrl: 'assets/images/swiggy_logo.png',
        icon: Icons.fastfood,
        color: Colors.orange,
        category: 'food',
      ),
      RedemptionVoucher(
        id: 'zomato_200',
        name: 'Zomato ₹200 Voucher',
        description: 'Get ₹200 off on your next Zomato order',
        pointsCost: 2000,
        imageUrl: 'assets/images/zomato_logo.png',
        icon: Icons.fastfood,
        color: Colors.red,
        category: 'food',
      ),
      RedemptionVoucher(
        id: 'bookmyshow_300',
        name: 'BookMyShow ₹300 Voucher',
        description: 'Get ₹300 off on movie tickets',
        pointsCost: 3000,
        imageUrl: 'assets/images/bookmyshow_logo.png',
        icon: Icons.movie,
        color: Colors.red,
        category: 'entertainment',
      ),
      RedemptionVoucher(
        id: 'decathlon_300',
        name: 'Decathlon ₹300 Voucher',
        description: 'Get ₹300 off on sports equipment',
        pointsCost: 3000,
        imageUrl: 'assets/images/decathlon_logo.png',
        icon: Icons.sports_tennis,
        color: Colors.blue,
        category: 'fitness',
      ),
    ]);
  }
  
  Future<void> _loadRedeemedVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final redeemedIds = prefs.getStringList('redeemed_vouchers') ?? [];
    _redeemedVoucherIds.clear();
    _redeemedVoucherIds.addAll(redeemedIds);
  }
  
  Future<bool> redeemVoucher(String voucherId) async {
    final voucher = _availableVouchers.firstWhere((v) => v.id == voucherId);
    final currentPoints = _profileService.profile.points;
    
    if (currentPoints < voucher.pointsCost) {
      return false; // Not enough points
    }
    
    // Deduct points
    final updatedProfile = _profileService.profile.copyWith(
      points: currentPoints - voucher.pointsCost,
    );
    await _profileService.updateProfile(points: updatedProfile.points);
    
    // Add to redeemed vouchers
    _redeemedVoucherIds.add(voucherId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('redeemed_vouchers', _redeemedVoucherIds);
    
    notifyListeners();
    return true;
  }
  
  List<RedemptionVoucher> getVouchersByCategory(String categoryId) {
    if (categoryId == 'all') {
      return _availableVouchers;
    }
    return _availableVouchers.where((v) => v.category == categoryId).toList();
  }
}
