/// Asset optimization utilities for efficient image loading
/// 
/// Key optimizations:
/// 1. Lazy loading - only load assets when needed
/// 2. WebP support - smaller files with same quality
/// 3. Resolution-aware loading - use device pixel ratio
/// 4. Caching - prevent redundant asset loads

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimized asset loader with lazy loading and caching
class AssetOptimizer {
  static final Map<String, ImageProvider> _imageCache = {};
  static final Set<String> _preloadedAssets = {};
  
  /// Tree asset paths - now supports both PNG and WebP
  static const List<String> treeTypes = ['oak', 'cherry', 'maple', 'pine', 'willow', 'baobab'];
  static const List<String> treeStages = ['sprout', 'sapling', 'mature'];
  
  /// Get tree image path with format preference
  static String getTreeImagePath(String treeType, String stage, {bool preferWebP = true}) {
    final extension = preferWebP ? 'webp' : 'png';
    return 'assets/images/trees/${treeType}_$stage.$extension';
  }
  
  /// Lazy load a single tree image (only when displayed)
  static ImageProvider getTreeImage(String treeType, String stage, {bool preferWebP = true}) {
    final path = getTreeImagePath(treeType, stage, preferWebP: preferWebP);
    
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }
    
    final provider = AssetImage(path);
    _imageCache[path] = provider;
    return provider;
  }
  
  /// Preload only the user's selected tree design
  static Future<void> preloadUserTree(
    BuildContext context,
    String treeType,
  ) async {
    for (final stage in treeStages) {
      final path = getTreeImagePath(treeType, stage);
      
      if (_preloadedAssets.contains(path)) continue;
      
      final provider = AssetImage(path);
      await precacheImage(provider, context);
      _imageCache[path] = provider;
      _preloadedAssets.add(path);
    }
  }
  
  /// Preload trees for a specific stage only (e.g., current progress)
  static Future<void> preloadTreesForStage(
    BuildContext context,
    String stage,
  ) async {
    for (final tree in treeTypes) {
      final path = getTreeImagePath(tree, stage);
      
      if (_preloadedAssets.contains(path)) continue;
      
      final provider = AssetImage(path);
      await precacheImage(provider, context);
      _imageCache[path] = provider;
      _preloadedAssets.add(path);
    }
  }
  
  /// Clear image cache (for memory management)
  static void clearCache() {
    _imageCache.clear();
    _preloadedAssets.clear();
    PaintingBinding.instance.imageCache.clear();
  }
  
  /// Get cache statistics
  static Map<String, int> getCacheStats() {
    return {
      'cachedImages': _imageCache.length,
      'preloadedAssets': _preloadedAssets.length,
      'systemCacheSize': PaintingBinding.instance.imageCache.currentSize,
      'systemCacheCount': PaintingBinding.instance.imageCache.liveImageCount,
    };
  }
}

/// Widget for optimized image display with resolution awareness
class OptimizedAssetImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  
  const OptimizedAssetImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image(
      image: ResolutionAwareAssetImage(path),
      width: width,
      height: height,
      fit: fit,
      color: color,
      // Use fadeIn for perceived performance
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: child,
        );
      },
      // Show placeholder while loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      // Graceful error handling
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(
          width: width,
          height: height,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}

/// Resolution-aware asset image that loads appropriate resolution variant
class ResolutionAwareAssetImage extends AssetImage {
  const ResolutionAwareAssetImage(super.assetName);
  
  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    // Flutter automatically handles resolution variants
    // This ensures we load 2x or 3x images on high-DPI screens
    return super.obtainKey(configuration);
  }
}

/// Memory-efficient tree display widget
class OptimizedTreeImage extends StatefulWidget {
  final String treeType;
  final String stage;
  final double? width;
  final double? height;
  
  const OptimizedTreeImage({
    super.key,
    required this.treeType,
    required this.stage,
    this.width,
    this.height,
  });
  
  @override
  State<OptimizedTreeImage> createState() => _OptimizedTreeImageState();
}

class _OptimizedTreeImageState extends State<OptimizedTreeImage> {
  late ImageProvider _imageProvider;
  
  @override
  void initState() {
    super.initState();
    _imageProvider = AssetOptimizer.getTreeImage(widget.treeType, widget.stage);
  }
  
  @override
  void didUpdateWidget(OptimizedTreeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.treeType != widget.treeType || oldWidget.stage != widget.stage) {
      _imageProvider = AssetOptimizer.getTreeImage(widget.treeType, widget.stage);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Image(
      image: _imageProvider,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame == null
              ? Container(
                  width: widget.width,
                  height: widget.height,
                  color: Colors.transparent,
                )
              : child,
        );
      },
    );
  }
}
