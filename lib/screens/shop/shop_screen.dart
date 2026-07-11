import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/tree_design.dart';
import '../../providers/app_state.dart';

/// Tree Nursery - Select tree species for your forest
class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Selector to only rebuild when coins or unlocked badges change
    // This prevents rebuilds when unrelated AppState properties change
    return Selector<AppState, ({int coins, List<String> unlockedIds})>(
      selector: (context, state) => (
        coins: state.userStats.coins,
        unlockedIds: state.userStats.unlockedBadgeIds,
      ),
      builder: (context, data, child) {
        final userCoins = data.coins;
        final unlockedIds = data.unlockedIds;
        final colors = context.colors;

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                const Text('🌱 '),
                Text(
                  'Tree Nursery',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.warning.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$userCoins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.success.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: colors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tree Life Cycle',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Each species grows through 7 stages:\nSeed → Sprout → Seedling → Sapling → Mature → Decline → Snag',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Species Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: TreeDesigns.all.length,
                  itemBuilder: (context, index) {
                    final design = TreeDesigns.all[index];
                    final isUnlocked =
                        unlockedIds.contains('tree_${design.id}') ||
                        design.cost == 0;
                    final canAfford = userCoins >= design.cost;

                    return _SpeciesCard(
                      design: design,
                      isUnlocked: isUnlocked,
                      canAfford: canAfford,
                      onPurchase: () => _purchaseSpecies(context, design),
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

  void _purchaseSpecies(BuildContext context, TreeDesign design) {
    final colors = context.colors;
    final state = context.read<AppState>();
    if (design.cost == 0) return;

    if (state.userStats.coins < design.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! Need ${design.cost} 🪙'),
          backgroundColor: colors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text('Unlock ${design.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(design.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              design.description,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.park_rounded, size: 16, color: colors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mature: ${design.matureDescription}',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 6),
                Text(
                  '${design.cost}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final purchased = state.purchaseTreeDesign(
                designId: design.id,
                cost: design.cost,
              );
              if (!purchased) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Not enough coins! Need ${design.cost} 🪙'),
                    backgroundColor: colors.danger,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🌱 Unlocked ${design.name}!'),
                  backgroundColor: colors.success,
                ),
              );
            },
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final TreeDesign design;
  final bool isUnlocked;
  final bool canAfford;
  final VoidCallback onPurchase;

  const _SpeciesCard({
    required this.design,
    required this.isUnlocked,
    required this.canAfford,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: isUnlocked ? null : onPurchase,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked
              ? colors.success.withAlpha(15)
              : colors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? colors.success.withAlpha(100)
                : canAfford
                ? colors.warning.withAlpha(100)
                : colors.glassBorder,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tree preview - Use cached image with proper loading
            _TreePreviewImage(design: design, isUnlocked: isUnlocked),
            const SizedBox(height: 12),
            Text(
              design.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(design.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ Owned',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.success,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${design.cost}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: canAfford ? colors.warning : colors.textMuted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Optimized tree image widget with caching and error handling
class _TreePreviewImage extends StatelessWidget {
  final TreeDesign design;
  final bool isUnlocked;

  const _TreePreviewImage({required this.design, required this.isUnlocked});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            design.getAssetPath(5), // Mature stage for preview
            width: 60,
            height: 70,
            fit: BoxFit.contain,
            // Use cacheWidth/cacheHeight to reduce memory usage
            cacheWidth: 120, // 2x for retina displays
            cacheHeight: 140,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to emoji
              return Text(design.emoji, style: const TextStyle(fontSize: 40));
            },
          ),
          if (!isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
