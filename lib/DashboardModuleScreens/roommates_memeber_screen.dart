import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expence_tracker/CommonWidgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class RoomMembers extends StatefulWidget {
  const RoomMembers({super.key});

  @override
  State<RoomMembers> createState() => _RoomMembersState();
}

class _RoomMembersState extends State<RoomMembers> {
  Future<List<Map<String, dynamic>>> getAllRoomMembers() async {
    // Fetch all users
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('users').get();

    // Convert to list of maps
    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 250),
      appBar: const CustomAppBar(
        title: "Room Members",
        subTitle: "Contacts of all room members",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getAllRoomMembers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF097D94)),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No users found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final members = snapshot.data!;

            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: (member['profilePic'] != null &&
                                  member['profilePic'].toString().isNotEmpty)
                              ? NetworkImage(member['profilePic'])
                              : const NetworkImage(
                                  'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${member['firstName'] ?? ''} ${member['lastName'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Email: ${member['emailId'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Contact: ${member['mobileNumber'] ?? 'N/A'}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
