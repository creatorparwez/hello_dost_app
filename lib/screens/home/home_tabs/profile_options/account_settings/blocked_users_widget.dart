import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlockedUsersWidget extends StatefulWidget {
  final String currentUserId;
  final List<String> blockedUserIds;
  const BlockedUsersWidget({
    super.key,
    required this.currentUserId,
    required this.blockedUserIds,
  });

  @override
  State<BlockedUsersWidget> createState() => _BlockedUsersWidgetState();
}

class _BlockedUsersWidgetState extends State<BlockedUsersWidget> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> blockedUsersData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBlockedUsers();
  }

  /// 🔹 Fetch all blocked users' details from Firestore
  Future<void> fetchBlockedUsers() async {
    if (widget.blockedUserIds.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Fetch all users in parallel
      List<Future<DocumentSnapshot>> futures = widget.blockedUserIds
          .map((id) => _firestore.collection('users').doc(id).get())
          .toList();

      final results = await Future.wait(futures);

      final List<Map<String, dynamic>> loadedUsers = results
          .where((doc) => doc.exists)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              "name": data['name'] ?? 'Unknown',
              "uid": doc.id,
              "imagePath": data['imagePath'] ?? '',
            };
          })
          .toList();

      setState(() {
        blockedUsersData = loadedUsers;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching blocked users: $e");
      setState(() => isLoading = false);
    }
  }

  /// 🔹 Unblock a user
  Future<void> unblockUser(String blockedUserId) async {
    try {
      // Remove from current user's blockedUsers array
      await _firestore.collection('users').doc(widget.currentUserId).update({
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
      });

      // Remove from local list and update UI
      setState(() {
        blockedUsersData.removeWhere((user) => user['uid'] == blockedUserId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error unblocking user: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unblock user: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 🔹 Show confirmation dialog before unblocking
  void showUnblockDialog(String userName, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unblock User'),
          content: Text('Are you sure you want to unblock $userName?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                unblockUser(userId);
              },
              child: const Text('Unblock', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          // Return the updated blocked user IDs list when back is pressed
          final updatedBlockedIds = blockedUsersData
              .map((user) => user['uid'] as String)
              .toList();
          Navigator.of(context).pop(updatedBlockedIds);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Blocked Users",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 29, 28, 28),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Return updated blocked user IDs when back button pressed
              final updatedBlockedIds = blockedUsersData
                  .map((user) => user['uid'] as String)
                  .toList();
              Navigator.of(context).pop(updatedBlockedIds);
            },
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : blockedUsersData.isEmpty
            ? const Center(child: Text("No blocked users"))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                child: ListView.builder(
                  itemCount: blockedUsersData.length,
                  itemBuilder: (context, index) {
                    final user = blockedUsersData[index];
                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.h),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user["imagePath"].isNotEmpty
                                ? AssetImage(user["imagePath"])
                                : null,
                            child: user["imagePath"].isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            user["name"],
                            style: TextStyle(fontSize: 20.sp),
                          ),

                          trailing: ElevatedButton(
                            onPressed: () =>
                                showUnblockDialog(user["name"], user["uid"]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Unblock'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
