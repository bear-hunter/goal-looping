import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme.dart';
import '../../models/tree_design.dart';
import '../../providers/app_state.dart';

/// Tree Nursery - Select tree species for your forest
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
                const Text('🌱 '),
                Text('Tree Nursery', style: TextStyle(color: AppColors.textPrimary)),
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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('Tree Life Cycle', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Each species grows through 7 stages:\nSeed → Sprout → Seedling → Sapling → Mature → Decline → Snag',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                    final isUnlocked = state.userStats.unlockedBadgeIds.contains('tree_${design.id}') || design.cost == 0;
                    final canAfford = userCoins >= design.cost;
                    
                    return _SpeciesCard(
                      design: design,
                      isUnlocked: isUnlocked,
                      canAfford: canAfford,
                      onPurchase: () => _purchaseSpecies(context, state, design),
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

  void _purchaseSpecies(BuildContext context, AppState state, TreeDesign design) {
    if (design.cost == 0) return;
    
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
        title: Text('Unlock ${design.name}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(design.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(design.description, style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.park_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mature: ${design.matureDescription}',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                Text('${design.cost}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.warning)),
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
              state.userStats.spendCoins(design.cost);
              state.userStats.unlockBadge('tree_${design.id}');
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🌱 Unlocked ${design.name}!'),
                  backgroundColor: AppColors.success,
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
    final leafColor = Color(int.parse('FF${design.colorHex}', radix: 16));
    
    return GestureDetector(
      onTap: isUnlocked ? null : onPurchase,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked 
              ? AppColors.success.withAlpha(15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked 
                ? AppColors.success.withAlpha(100)
                : canAfford ? AppColors.warning.withAlpha(100) : AppColors.glassBorder,
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tree preview
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(60, 70),
                  painter: _MatureTreePreviewPainter(leafColor: leafColor),
                ),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              design.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              design.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '✓ Owned',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success),
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
                      color: canAfford ? AppColors.warning : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

/// Preview of mature tree silhouette
class _MatureTreePreviewPainter extends CustomPainter {
  final Color leafColor;

  _MatureTreePreviewPainter({required this.leafColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottom = size.height;
    
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF5D4037)..style = PaintingStyle.fill;
    final trunkPath = Path();
    trunkPath.moveTo(centerX - 5, bottom);
    trunkPath.lineTo(centerX - 3, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 3, bottom - size.height * 0.35);
    trunkPath.lineTo(centerX + 5, bottom);
    trunkPath.close();
    canvas.drawPath(trunkPath, trunkPaint);
    
    // Foliage
    final leafPaint = Paint()..color = leafColor;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.5),
        width: size.width * 0.8,
        height: size.height * 0.4,
      ),
      leafPaint,
    );
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, bottom - size.height * 0.7),
        width: size.width * 0.5,
        height: size.height * 0.25,
      ),
      Paint()..color = Color.lerp(leafColor, Colors.black, 0.1)!,
    );
  }

  @override
  bool shouldRepaint(covariant _MatureTreePreviewPainter old) => leafColor != old.leafColor;
}
