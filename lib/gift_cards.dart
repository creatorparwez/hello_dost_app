import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zee_goo/gift_overlay_manager.dart';
import 'package:zego_uikit/zego_uikit.dart';

class GiftCardsScreen extends StatefulWidget {
  const GiftCardsScreen({super.key});

  @override
  State<GiftCardsScreen> createState() => _GiftCardsScreenState();
}

class _GiftCardsScreenState extends State<GiftCardsScreen> {
  List<String> giftOptions = [
    "assets/gifts/rose.png",
    "assets/gifts/cake.png",
    "assets/gifts/chocolate.png",
    "assets/gifts/diamond-ring.png",
    "assets/gifts/crown.png",
  ];

  int? selectedGift; // store index of selected card
  String? selectedImage;
  // Send gift message to callee via ZegoCloud
  Future<void> sendGiftMessage(String imagePath) async {
    try {
      final messageData = jsonEncode({'type': 'gift', 'imagePath': imagePath});
      debugPrint('📤 Attempting to send gift command: $messageData');

      final success = await ZegoUIKit().sendInRoomCommand(messageData, []);

      if (success) {
        debugPrint('✅ Gift command sent successfully: $imagePath');
      } else {
        debugPrint('❌ Failed to send gift command');
      }
    } catch (e) {
      debugPrint('❌ Exception while sending gift: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (BuildContext context) {
            int? tempSelectedGift = selectedGift;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Choose a Gift",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // 🎁 Gift Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: giftOptions.length,
                        itemBuilder: (context, index) {
                          final imagePath = giftOptions[index];
                          final isSelected = tempSelectedGift == index;

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempSelectedGift = index;
                              });
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: isSelected ? 3 : 1,
                                  color: isSelected
                                      ? Colors.deepOrange
                                      : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(50.r),
                              ),
                              child: Image.asset(
                                imagePath,
                                height: 30.h,
                                width: 30.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 12.h),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: tempSelectedGift == null
                            ? null
                            : () async {
                                setState(() {
                                  selectedGift = tempSelectedGift;
                                  selectedImage =
                                      giftOptions[tempSelectedGift!];
                                  print('hhhhh selected imgg $selectedImage');
                                });
                                Navigator.pop(context);

                                // Show the gift overlay for sender using global manager
                                GiftOverlayManager().showGift(selectedImage!);

                                // Send gift command to other user
                                await sendGiftMessage(selectedImage!);
                              },
                        child: const Center(
                          child: Text(
                            "Send Gift",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Icon(Icons.card_giftcard),
    );
  }
}
