import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GiftOverlayManager {
  static final GiftOverlayManager _instance = GiftOverlayManager._internal();
  factory GiftOverlayManager() => _instance;
  GiftOverlayManager._internal();

  final GlobalKey<_GiftOverlayWidgetState> _overlayKey = GlobalKey();

  GlobalKey<_GiftOverlayWidgetState> get overlayKey => _overlayKey;

  void showGift(String imagePath) {
    debugPrint('🎁 GiftOverlayManager: Showing gift: $imagePath');
    _overlayKey.currentState?.showGift(imagePath);
  }
}

/// This widget should be placed at the root of your app (in MaterialApp's builder)
class GiftOverlayWidget extends StatefulWidget {
  final Widget child;

  const GiftOverlayWidget({super.key, required this.child});

  @override
  State<GiftOverlayWidget> createState() => _GiftOverlayWidgetState();
}

class _GiftOverlayWidgetState extends State<GiftOverlayWidget>
    with SingleTickerProviderStateMixin {
  String? _currentGiftImage;
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );
  }

  void showGift(String imagePath) {
    debugPrint('🎁 _GiftOverlayWidgetState: Showing gift: $imagePath');
    setState(() {
      _currentGiftImage = imagePath;
    });

    _animationController?.forward(from: 0.0);

    // Hide after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentGiftImage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main app content
        widget.child,

        // The gift overlay (shown on top)
        if (_currentGiftImage != null)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(
                color: Colors.black.withAlpha(25),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController!,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation!.value,
                        child: Opacity(
                          opacity: _opacityAnimation!.value,
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      _currentGiftImage!,
                      width: 160.w,
                      height: 160.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
