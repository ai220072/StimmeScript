import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageProfile extends StatefulWidget {
  const ManageProfile({super.key});

  @override
  ManageProfileState createState() => ManageProfileState();
}

class ManageProfileState extends State<ManageProfile> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in.";
          isLoading = false;
        });
        return;
      }

      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "User data not found in the database.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching user data: $e";
        isLoading = false;
      });
    }
  }

  Widget buildProfileRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profile'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF0000), Color(0xFFB22222)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    // Gradient Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 60, bottom: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 50, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userData?['name'] ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          buildProfileRow(Icons.email, userData?['email'] ?? 'Email'),
                          buildProfileRow(Icons.lock, 'Password'),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF0000), Color(0xFFB22222)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/editprofile', arguments: userData);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Edit profile',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ), 

                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () async {
                              try {
                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(email: user.email!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Password reset email sent.')),
                                    );
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
