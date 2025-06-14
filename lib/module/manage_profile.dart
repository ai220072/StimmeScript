import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'animation/determinate_progress_indicator.dart';

class DeterminateLinearIndicator extends StatelessWidget {
  final String label;
  final double progress;

  const DeterminateLinearIndicator({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: progress),
          duration: const Duration(milliseconds: 500),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[300],
              color: Colors.red[700],
              minHeight: 8,
            );
          },
        ),
      ],
    );
  }
}

class ManageProfile extends StatefulWidget {
  const ManageProfile({super.key});

  @override
  ManageProfileState createState() => ManageProfileState();
}

class ManageProfileState extends State<ManageProfile> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;
  double _progress = 0.0;
  String errorMessage = '';
  final ValueNotifier<double> progressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserData();
    });
  }

  Future<void> fetchUserData() async {
    setState(() {
      _isLoading = true;
      _progress = 0.0;
      progressNotifier.value = 0.0;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      progressNotifier.value = 0.3;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = "User not logged in.";
          _isLoading = false;
        });
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      progressNotifier.value = 0.6;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      await Future.delayed(const Duration(milliseconds: 300));
      progressNotifier.value = 1.0;

      if (snapshot.exists) {
        setState(() {
          userData = snapshot.data() as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "User data not found in the database.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching user data: $e";
        _isLoading = false;
      });
    }
  }

  Widget buildProfileRow(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
      body: _isLoading
          ? Center(
              child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/animations/Pen.gif',
                    fit: BoxFit.fitHeight,
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  DeterminateLinearIndicator(
                    label: 'Fetching user...',
                    progress: _progress,
                  ),
                ],
              ),
            ))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    Stack(
                      children: [
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
                        Positioned(
                          top: 70,
                          right: 20,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/editprofile', arguments: userData);
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.edit, color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          buildProfileRow(Icons.email, userData?['email'] ?? 'Email'),
                          buildProfileRow(Icons.lock, 'Password'),
                          buildProfileRow(
                            Icons.info_outline,
                            'About Device',
                            onTap: () => showAboutDeviceDialog(context),
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
                                      const SnackBar(content: Text('Password reset email sent.')),
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
                          const SizedBox(height: 10),
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
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Log Out',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
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

void showAboutDeviceDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("About Device"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(
            leading: Icon(Icons.system_update_alt, color: Colors.red),
            title: Text("Version"),
            subtitle: Text("1.0.0"),
          ),
          ListTile(
            leading: Icon(Icons.update, color: Colors.red),
            title: Text("Last Update"),
            subtitle: Text("June 14, 2025"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
