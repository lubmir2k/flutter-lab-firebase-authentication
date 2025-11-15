import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ListUsersScreen extends StatefulWidget {
  const ListUsersScreen({super.key});

  @override
  State<ListUsersScreen> createState() => _ListUsersScreenState();
}

class _ListUsersScreenState extends State<ListUsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final currentUserEmail = _auth.currentUser?.email;
      if (currentUserEmail == null) return;

      final querySnapshot = await _firestore.collection('avatars').get();

      final fetchedUsers = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'email': doc.data()['email'] as String?,
          'avatar': doc.data()['avatar'] as String?,
        };
      }).toList();

      // Find current user and other users
      Map<String, dynamic>? currentUser;
      final otherUsers = <Map<String, dynamic>>[];

      for (var user in fetchedUsers) {
        if (user['email'] == currentUserEmail) {
          currentUser = user;
        } else {
          otherUsers.add(user);
        }
      }

      // Put current user first, then others
      setState(() {
        _users = currentUser != null ? [currentUser, ...otherUsers] : otherUsers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA1EDA4),
      appBar: AppBar(
        title: const Text('Buddies'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'No users found. Create an avatar in Settings.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final email = user['email'] ?? 'Unknown';
                    final avatar = user['avatar'];
                    final isCurrentUser = email == _auth.currentUser?.email;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: avatar != null && avatar.isNotEmpty
                              ? NetworkImage(avatar)
                              : null,
                          child: avatar == null || avatar.isEmpty
                              ? Text(email[0].toUpperCase())
                              : null,
                        ),
                        title: Text(
                          email,
                          style: TextStyle(
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: isCurrentUser
                            ? const Text('You')
                            : null,
                        onTap: isCurrentUser
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      receiverEmail: email,
                                      receiverAvatar: avatar ?? '',
                                    ),
                                  ),
                                );
                              },
                        trailing: isCurrentUser
                            ? null
                            : const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
