import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/redemption_voucher.dart';
import '../services/redemption_service.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';

class RedemptionScreen extends StatefulWidget {
  const RedemptionScreen({Key? key}) : super(key: key);

  @override
  State<RedemptionScreen> createState() => _RedemptionScreenState();
}

class _RedemptionScreenState extends State<RedemptionScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer2<RedemptionService, ProfileService>(
      builder: (context, redemptionService, profileService, _) {
        final availableVouchers = redemptionService.getVouchersByCategory(_selectedCategory);
        final userPoints = profileService.profile.points;
        
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Redeem Points',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Points display
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
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
                            color: AppTheme.accentColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Categories
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('all', 'All', Icons.category),
                    ...redemptionService.categories.map((category) {
                      return _buildCategoryChip(
                        category.id,
                        category.name,
                        category.icon,
                      );
                    }),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Vouchers
              Expanded(
                child: availableVouchers.isEmpty
                    ? const Center(
                        child: Text(
                          'No vouchers available in this category',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: availableVouchers.length,
                        itemBuilder: (context, index) {
                          final voucher = availableVouchers[index];
                          return _buildVoucherCard(
                            voucher,
                            userPoints,
                            redemptionService,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String id, String name, IconData icon) {
    final isSelected = _selectedCategory == id;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: AppTheme.cardColor,
        selectedColor: AppTheme.accentColor.withOpacity(0.3),
        label: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.accentColor : Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? AppTheme.accentColor : Colors.white,
              ),
            ),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = id;
          });
        },
      ),
    );
  }

  Widget _buildVoucherCard(
    RedemptionVoucher voucher,
    int userPoints,
    RedemptionService redemptionService,
  ) {
    final bool canRedeem = userPoints >= voucher.pointsCost;
    final bool isRedeemed = redemptionService.redeemedVoucherIds.contains(voucher.id);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voucher header
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: voucher.color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Icon(
                voucher.icon,
                size: 40,
                color: voucher.color,
              ),
            ),
          ),
          
          // Voucher details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  voucher.description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      voucher.pointsCost.toString(),
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Redeem button
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isRedeemed || !canRedeem
                        ? null
                        : () => _redeemVoucher(voucher, redemptionService),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isRedeemed
                          ? 'Redeemed'
                          : canRedeem
                              ? 'Redeem'
                              : 'Not Enough Points',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _redeemVoucher(RedemptionVoucher voucher, RedemptionService redemptionService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          'Confirm Redemption',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to redeem ${voucher.name} for ${voucher.pointsCost} points?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.black,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await redemptionService.redeemVoucher(voucher.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully redeemed ${voucher.name}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to redeem voucher. Not enough points.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
