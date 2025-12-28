import 'package:hive/hive.dart';

part 'tree_design.g.dart';

/// Tree Species that can be unlocked with coins
/// Each species has unique visual appearance at each life stage
@HiveType(typeId: 22)
class TreeDesign extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String emoji; // Representative emoji

  @HiveField(3)
  int cost; // Cost in coins (0 = free)

  @HiveField(4)
  bool isUnlocked;

  @HiveField(5)
  String colorHex; // Primary leaf color

  @HiveField(6)
  String description;

  @HiveField(7)
  String trunkColorHex; // Trunk color

  @HiveField(8)
  String matureDescription; // What it looks like when mature

  TreeDesign({
    required this.id,
    required this.name,
    required this.emoji,
    this.cost = 0,
    this.isUnlocked = false,
    this.colorHex = '4CAF50',
    this.trunkColorHex = '5D4037',
    this.description = '',
    this.matureDescription = '',
  });
}

/// Predefined tree species
/// Each species progresses through: Seed → Sprout → Seedling → Sapling → Mature → Decline → Snag
class TreeDesigns {
  static final List<TreeDesign> all = [
    TreeDesign(
      id: 'oak',
      name: 'Oak',
      emoji: '🌳',
      cost: 0,
      isUnlocked: true,
      colorHex: '4CAF50', // Classic green
      trunkColorHex: '5D4037',
      description: 'A sturdy classic deciduous tree',
      matureDescription: 'Full round canopy with strong branches',
    ),
    TreeDesign(
      id: 'pine',
      name: 'Pine',
      emoji: '🌲',
      cost: 100,
      colorHex: '2E7D32', // Deep green
      trunkColorHex: '5D4037',
      description: 'An evergreen conifer',
      matureDescription: 'Tall triangular shape with layered branches',
    ),
    TreeDesign(
      id: 'cherry',
      name: 'Cherry Blossom',
      emoji: '🌸',
      cost: 200,
      colorHex: 'F48FB1', // Pink blossoms
      trunkColorHex: '6D4C41',
      description: 'Delicate pink flowering tree',
      matureDescription: 'Beautiful pink blossoms in spring',
    ),
    TreeDesign(
      id: 'willow',
      name: 'Weeping Willow',
      emoji: '🌿',
      cost: 300,
      colorHex: '8BC34A', // Light green
      trunkColorHex: '795548',
      description: 'Graceful drooping branches',
      matureDescription: 'Long cascading branches touch the ground',
    ),
    TreeDesign(
      id: 'maple',
      name: 'Maple',
      emoji: '🍁',
      cost: 500,
      colorHex: 'FF7043', // Orange fall color
      trunkColorHex: '5D4037',
      description: 'Brilliant autumn colors',
      matureDescription: 'Stunning red and orange leaves in fall',
    ),
    TreeDesign(
      id: 'baobab',
      name: 'Baobab',
      emoji: '🏝️',
      cost: 1000,
      colorHex: '66BB6A', // Sparse green
      trunkColorHex: '8D6E63',
      description: 'Exotic African tree of life',
      matureDescription: 'Massive thick trunk with sparse canopy',
    ),
  ];

  static TreeDesign getById(String id) {
    return all.firstWhere((t) => t.id == id, orElse: () => all.first);
  }
}
