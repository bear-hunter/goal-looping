import 'package:hive/hive.dart';

part 'tree_design.g.dart';

/// Tree design that can be unlocked with coins
@HiveType(typeId: 22)
class TreeDesign extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji; // Fallback emoji

  @HiveField(3)
  int cost; // Cost in coins (0 = free)

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  String colorHex; // Primary color for the tree

  @HiveField(6)
  String description;

  TreeDesign({
    required this.id,
    required this.name,
    required this.emoji,
    this.cost = 0,
    this.isUnlocked = false,
    this.colorHex = '4CAF50',
    this.description = '',
  });
}

/// Predefined tree designs
class TreeDesigns {
  static final List<TreeDesign> all = [
    TreeDesign(
      id: 'oak',
      name: 'Oak',
      emoji: '🌳',
      cost: 0,
      isUnlocked: true,
      colorHex: '4CAF50',
      description: 'A sturdy classic tree',
    ),
    TreeDesign(
      id: 'cherry',
      name: 'Cherry Blossom',
      emoji: '🌸',
      cost: 100,
      colorHex: 'E91E63',
      description: 'Delicate pink blossoms',
    ),
    TreeDesign(
      id: 'pine',
      name: 'Pine',
      emoji: '🌲',
      cost: 150,
      colorHex: '2E7D32',
      description: 'An evergreen classic',
    ),
    TreeDesign(
      id: 'bonsai',
      name: 'Bonsai',
      emoji: '🌿',
      cost: 200,
      colorHex: '689F38',
      description: 'Carefully cultivated miniature',
    ),
    TreeDesign(
      id: 'crystal',
      name: 'Crystal',
      emoji: '💎',
      cost: 500,
      colorHex: '00BCD4',
      description: 'Rare sparkling crystal tree',
    ),
    TreeDesign(
      id: 'gold',
      name: 'Golden',
      emoji: '✨',
      cost: 1000,
      colorHex: 'FFD700',
      description: 'The ultimate status symbol',
    ),
  ];

  static TreeDesign getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }
}
