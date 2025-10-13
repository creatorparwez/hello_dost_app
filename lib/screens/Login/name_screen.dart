import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zee_goo/models/user_model.dart';
import 'package:zee_goo/providers/User/user_provider.dart';
import 'package:zee_goo/repository/zego_services.dart';
import 'package:zee_goo/screens/Login/permission_waiting_screen.dart';
import 'package:zee_goo/screens/home/m_screen.dart';

class NameScreen extends ConsumerStatefulWidget {
  final String gender;
  const NameScreen({super.key, required this.gender});

  @override
  ConsumerState<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends ConsumerState<NameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _nameError; // <-- state variable for validator

  @override
  void initState() {
    super.initState();
    _generateRandomName();
  }

  /// Generate random default name
  void _generateRandomName() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final uidPart = currentUser.uid.substring(0, 5);
      final randomNumber = Random().nextInt(9000) + 1000;
      _nameController.text = "User$randomNumber$uidPart";
    }
  }

  /// Check uniqueness in Firestore
  Future<bool> _isNameUnique(String value) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: value.trim())
        .get();
    return query.docs.isEmpty;
  }

  Future<void> saveName(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    ref.read(isLoadingProvider.notifier).state = true;

    final useruid = FirebaseAuth.instance.currentUser!.uid;
    final newName = _nameController.text.trim();

    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(useruid)
            .update({"name": newName});

        if (!mounted) return;
        ref.read(isLoadingProvider.notifier).state = false;

        // Navigate based on gender
        if (widget.gender == "Male") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PermissionWaitingScreen()),
          );
        }

        // Initialize Zego
        final currentUser = FirebaseAuth.instance.currentUser!;
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        final userData = UserModel.fromMap(userDoc.data()!, userDoc.id);
        await ZegoServices.requestPermissions();
        await ZegoServices.initZego(currentUser.uid, userData.name);
      } catch (e) {
        if (mounted) {
          ref.read(isLoadingProvider.notifier).state = false;
          setState(() {
            _nameError = "Failed to save name: $e";
          });
        }
      }
    } else {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose a Username",
                style: TextStyle(fontSize: 35.sp, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 40.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.user),
                  hintText: "Choose a Username",
                  errorText: _nameError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
                validator: (value) {
                  if (_nameError != null) return _nameError;
                  if (value == null || value.trim().isEmpty)
                    return "Name cannot be empty";
                  return null;
                },
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                onPressed: () async {
                  setState(() {
                    _nameError = null; // reset before validation
                  });

                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    setState(() {
                      _nameError = "Name cannot be empty";
                    });
                    _formKey.currentState!.validate();
                    return;
                  }

                  final unique = await _isNameUnique(name);
                  if (!unique) {
                    setState(() {
                      _nameError =
                          "This username is unavailable. Can you try a different one?";
                    });
                    _formKey.currentState!.validate();
                    return;
                  }

                  await saveName(context, ref);
                },
                child: Center(
                  child: loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
