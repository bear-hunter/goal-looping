import 'package:flutter/material.dart';
import '../core/theme/theme.dart';

/// A horizontal scroll view with fade gradient indicators
/// showing when more content is available off-screen.
class FadingHorizontalScroll extends StatefulWidget {
  final Widget child;
  final double fadeWidth;

  const FadingHorizontalScroll({
    super.key,
    required this.child,
    this.fadeWidth = 24,
  });

  @override
  State<FadingHorizontalScroll> createState() => _FadingHorizontalScrollState();
}

class _FadingHorizontalScrollState extends State<FadingHorizontalScroll> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateFadeVisibility);
    // Check initial state after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateFadeVisibility());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateFadeVisibility);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFadeVisibility() {
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    final showLeft = position.pixels > 0;
    final showRight = position.pixels < position.maxScrollExtent;
    
    if (showLeft != _showLeftFade || showRight != _showRightFade) {
      setState(() {
        _showLeftFade = showLeft;
        _showRightFade = showRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: widget.child,
        ),
        // Left fade indicator
        if (_showLeftFade)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: widget.fadeWidth,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.surface,
                      colors.surface.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Right fade indicator
        if (_showRightFade)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: widget.fadeWidth,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [
                      colors.surface,
                      colors.surface.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
