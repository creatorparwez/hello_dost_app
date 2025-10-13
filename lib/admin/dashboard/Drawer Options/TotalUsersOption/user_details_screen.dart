import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String phone;
  final String gender;
  final String age;
  final double balance;
  final List<String> languages;
  final List<String> interests;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.gender,
    required this.phone,
    required this.balance,
    required this.age,
    required this.languages,
    required this.interests,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _genderController = TextEditingController();
  final _ageController = TextEditingController();
  final _coinsController = TextEditingController();

  Future<void> saveUserUpdatedData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
            "name": _nameController.text.trim(),
            "phone": _phoneController.text.trim(),
            "gender": _genderController.text.trim(),
            "age": _ageController.text.trim(),
            "balance": _coinsController,
          });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "User updated successfully");
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.clear();
    _phoneController.clear();
    _genderController.clear();
    _ageController.clear();
    _coinsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF141D3C),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 90,
                backgroundImage: widget.gender == 'Female'
                    ? const AssetImage('assets/gender/female.png')
                    : const AssetImage('assets/gender/male_2.png'),
              ),
            ),
            SizedBox(height: 20.h),
            _buildSections(title: "Name", value: widget.userName),
            _buildSections(title: "Phone", value: widget.phone),
            _buildSections(title: "Gender", value: widget.gender),
            _buildSections(title: "Age", value: widget.age),
            _buildSections(title: "Coins", value: widget.balance.toString()),

            // Languages in one line
            _buildListSection(title: "Languages", values: widget.languages),

            // Interests in one line
            _buildListSection(title: "Interests", values: widget.interests),
            SizedBox(height: 30.h),
            // Edit User Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                // Navigate to Edit Dialog
                _nameController.text = widget.userName;
                _phoneController.text = widget.phone;
                _genderController.text = widget.gender;
                _ageController.text = widget.age;
                _coinsController.text = widget.balance.toString();
                _nameController.text = widget.userName;
                _nameController.text = widget.userName;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        width: 1.sw,

                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Update User",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15.h),
                              _editUserTextFormField(
                                label: "Name",
                                controller: _nameController,
                              ),
                              _editUserTextFormField(
                                label: "Phone",
                                controller: _phoneController,
                              ),
                              _editUserTextFormField(
                                label: "Gender",
                                controller: _genderController,
                                isDropdown: true,
                                dropdownItems: ["Male", "Female"],
                              ),

                              _editUserTextFormField(
                                label: "Age",
                                controller: _ageController,
                              ),
                              _editUserTextFormField(
                                label: "Coins",
                                controller: _coinsController,
                              ),

                              SizedBox(height: 20.h),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        ); // save and close
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          18,
                                          57,
                                          230,
                                        ),
                                      ),
                                      onPressed: () {
                                        // save and close
                                        saveUserUpdatedData();
                                      },
                                      child: Text(
                                        "Save",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Center(
                child: Text(
                  "Edit User",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 19.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSections({required String title, required String value}) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          children: [
            Text("$title: ", style: TextStyle(fontSize: 20.sp)),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Widget to show list of values in one line
  Widget _buildListSection({
    required String title,
    required List<String> values,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$title: ", style: TextStyle(fontSize: 20.sp)),
            Expanded(
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: values.map((val) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      val,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _editUserTextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDropdown;
  final List<String>? dropdownItems;

  const _editUserTextFormField({
    super.key,
    required this.label,
    required this.controller,
    this.isDropdown = false,
    this.dropdownItems,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 65.w,
            child: Text(label, style: TextStyle(fontSize: 16.sp)),
          ),
          Expanded(
            child: isDropdown
                ? DropdownButtonFormField<String>(
                    value: controller.text.isEmpty ? null : controller.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 12.h,
                      ),
                    ),
                    items: dropdownItems!
                        .map(
                          (item) =>
                              DropdownMenuItem(value: item, child: Text(item)),
                        )
                        .toList(),
                    onChanged: (value) {
                      controller.text = value!; // store selected value
                    },
                  )
                : TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Enter $label",
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 12.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
