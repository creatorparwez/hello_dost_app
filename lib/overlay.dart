import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showGiftOverlay(BuildContext context, String imagePath) {
  try {
    // Try to find the overlay in the current context tree
    final overlay = Overlay.of(context, rootOverlay: true);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Semi-transparent background (optional)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          // 🎁 Centered animated image
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              ),
              child: Image.asset(
                imagePath,
                width: 160.w,
                height: 160.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(entry);

    // 🕒 Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  } catch (e) {
    debugPrint('❌ Error showing gift overlay: $e');
  }
}
