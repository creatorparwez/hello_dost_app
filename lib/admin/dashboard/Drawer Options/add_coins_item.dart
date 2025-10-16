import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zee_goo/providers/User/buy_coins_provider.dart';

class AddCoinsItems extends ConsumerStatefulWidget {
  const AddCoinsItems({super.key});

  @override
  ConsumerState<AddCoinsItems> createState() => _AddCoinsItemsState();
}

class _AddCoinsItemsState extends ConsumerState<AddCoinsItems> {
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _discountPriceController =
      TextEditingController();
  final TextEditingController _originalPriceController =
      TextEditingController();

  Future<void> addCoinsData() async {
    // Validation
    if (_coinsController.text.isEmpty ||
        _discountPriceController.text.isEmpty ||
        _originalPriceController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        backgroundColor: Colors.red,
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('buy_coins').add({
        "coins": int.parse(_coinsController.text.trim()),
        "discountPrice": double.parse(_discountPriceController.text.trim()),
        "originalPrice": double.parse(_originalPriceController.text.trim()),
        "createdAt": FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(
        msg: "Item Added Successfully",
        backgroundColor: Colors.deepOrange,
      );
      // clear fields and close dialog
      _coinsController.clear();
      _discountPriceController.clear();
      _originalPriceController.clear();
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    }
  }

  Future<void> deleteCoinsData(String cardUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('buy_coins')
          .doc(cardUid)
          .delete();
      Fluttertoast.showToast(
        msg: "Item Deleted Successfully",
        backgroundColor: Colors.deepOrange,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyCoinsAsync = ref.watch(buyCoinsProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Add Coins",
          style: TextStyle(color: Colors.white, fontSize: 26.sp),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: const Color(0xFF141D3C),
      ),
      body: buyCoinsAsync.when(
        data: (buyCoinsData) {
          // Sort ascending
          buyCoinsData.sort((a, b) => a.coins.compareTo(b.coins));

          return Stack(
            children: [
              /// GridView
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    bottom: 100.h,
                  ), // space for floating btn
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: buyCoinsData.length,
                  itemBuilder: (context, index) {
                    var data = buyCoinsData[index];

                    return Card(
                      elevation: 5,
                      color: const Color.fromARGB(255, 19, 22, 26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                // Delete Logic
                                await deleteCoinsData(data.id);
                              },
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 24.sp,
                              ),
                            ),
                          ),
                          // Content
                          Center(
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min, // 👈 prevents overflow
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/dollar.png',
                                  height: 32.h,
                                  width: 32.w,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  data.coins.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.sp,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "₹${data.originalPrice.toInt()}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.white,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      "₹${data.discountPrice}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        error: (err, _) => Center(child: Text(err.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      // Floating Button to add items of coins
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.r),
        ),
        onPressed: () {
          // Dialog to add items
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 25.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Add Items",
                        style: TextStyle(
                          color: const Color(0xFF141D3C),
                          fontSize: 25.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Coins
                      TextFormField(
                        controller: _coinsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter Coins",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // DiscounPrice
                      TextFormField(
                        controller: _discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter discountPrice",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // OriginalPrice
                      TextFormField(
                        controller: _originalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter originalPrice",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                              onPressed: () {
                                // Back
                                Navigator.pop(context);
                              },
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF141D3C),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                ),
                              ),
                              onPressed: () async {
                                // Add Items Logic
                                await addCoinsData();
                              },
                              child: Center(
                                child: Text(
                                  "Add",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white, size: 30.sp),
      ),
    );
  }
}
