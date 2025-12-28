import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/tree_design.dart';
import '../../providers/app_state.dart';

/// Coin shop for purchasing tree designs
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final userCoins = state.userStats.coins;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Text('🏪 '),
                Text('Tree Shop', style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('$userCoins', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: TreeDesigns.all.length,
            itemBuilder: (context, index) {
              final design = TreeDesigns.all[index];
              final isUnlocked = state.userStats.unlockedBadgeIds.contains('tree_${design.id}') || design.cost == 0;
              final canAfford = userCoins >= design.cost;
              
              return _TreeDesignCard(
                design: design,
                isUnlocked: isUnlocked,
                canAfford: canAfford,
                onPurchase: () => _purchaseTree(context, state, design),
              );
            },
          ),
        );
      },
    );
  }

  void _purchaseTree(BuildContext context, AppState state, TreeDesign design) {
    if (design.cost == 0) return; // Free
    
    if (state.userStats.coins < design.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! Need ${design.cost} 🪙'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Purchase ${design.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(design.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(design.description, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${design.cost} 🪙', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (state.userStats.spendCoins(design.cost)) {
                state.userStats.unlockBadge('tree_${design.id}');
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Unlocked ${design.name}!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}

class _TreeDesignCard extends StatelessWidget {
  final TreeDesign design;
  final bool isUnlocked;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _TreeDesignCard({
    required this.design,
    required this.isUnlocked,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromHex(design.colorHex);
    
    return GestureDetector(
      onTap: isUnlocked ? null : onPurchase,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? color.withAlpha(15)
              : canAfford 
                  ? AppColors.surfaceLight 
                  : AppColors.surfaceLight.withAlpha(100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnlocked ? color : AppColors.glassBorder,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              design.emoji,
              style: TextStyle(
                fontSize: 48,
                color: isUnlocked ? null : (canAfford ? null : AppColors.textMuted),
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
            const SizedBox(height: 12),
            Text(
              design.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('✓ Unlocked', style: TextStyle(fontSize: 11, color: AppColors.success)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: canAfford ? AppColors.warning.withAlpha(30) : AppColors.textMuted.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🪙 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '${design.cost}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canAfford ? AppColors.warning : AppColors.textMuted,
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

  Color _getColorFromHex(String hex) {
    final code = hex.replaceAll('#', '');
    return Color(int.parse('FF$code', radix: 16));
  }
}
