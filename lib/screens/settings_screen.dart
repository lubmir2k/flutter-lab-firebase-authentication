import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _avatarController = TextEditingController();

  String? _avatar;
  String? _userEmail;
  DocumentReference? _docRef;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _userEmail = currentUser.email;
      });
      await _fetchAvatar();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
    }
  }

  Future<void> _fetchAvatar() async {
    try {
      final currentUserEmail = _auth.currentUser?.email;
      if (currentUserEmail == null) return;

      final querySnapshot = await _firestore
          .collection('avatars')
          .where('email', isEqualTo: currentUserEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docItem = querySnapshot.docs.first;
        _docRef = _firestore.collection('avatars').doc(docItem.id);

        final avatarData = docItem.data()['avatar'] as String?;
        if (avatarData != null) {
          setState(() {
            _avatar = avatarData;
            _avatarController.text = avatarData;
          });
        }
      }
    } catch (error) {
      print('Error getting document: $error');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (_userEmail == null) return;

    setState(() => _isLoading = true);

    try {
      final avatarUrl = _avatarController.text.trim();

      if (_docRef == null) {
        // Create new document
        await _firestore.collection('avatars').add({
          'email': _userEmail,
          'avatar': avatarUrl,
        });
      } else {
        // Update existing document
        await _docRef!.set({
          'email': _userEmail,
          'avatar': avatarUrl,
        });
      }

      setState(() {
        _avatar = avatarUrl;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $error')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA1EDA4),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Change the avatar!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(75),
                      ),
                      child: _avatar != null && _avatar!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(75),
                              child: Image.network(
                                _avatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text(
                                      'Upload Avatar',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Upload Avatar',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Avatar URL',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _avatarController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Avatar URL',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _avatar = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
