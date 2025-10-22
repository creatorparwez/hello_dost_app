import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RandomUserIdWidget extends StatefulWidget {
  const RandomUserIdWidget({super.key});

  @override
  State<RandomUserIdWidget> createState() => _RandomUserIdWidgetState();
}

class _RandomUserIdWidgetState extends State<RandomUserIdWidget> {
  String? randomUserId;
  String? name;
  bool isLoading = false;
  Future<void> getrandomUserId() async {
    setState(() => isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      if (snapshot.docs.isEmpty) {
        setState(() {
          randomUserId = 'No users found';
          name = "No user";
        });
        return;
      }

      // Pick Random Document
      final random = Random();
      final randomDoc = snapshot.docs[random.nextInt(snapshot.docs.length)];
      final data = randomDoc.data();
      final userName = data['name'] ?? "Guest User";

      setState(() {
        randomUserId = randomDoc.id;
        name = userName;
      });
    } catch (e) {
      setState(() {
        randomUserId = 'Error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Rander UserId : $randomUserId")),
          Center(child: Text("Name : $name")),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () async {
                // Random UserId
                await getrandomUserId();
              },
              child: Center(child: Text("Random User Id")),
            ),
          ),
        ],
      ),
    );
  }
}
