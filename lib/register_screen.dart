import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> addUser(String userId, String name, String email) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(userId).set({
        'name': name,
        'email': email,
      }, SetOptions(merge: true));
      print("User profile added/updated successfully!");
    } catch (error) {
      print("Failed to add/update user: $error");
    }
  }

  void _validateAndRegister() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showDialog("Error", "All fields are required!");
      return;
    }

    if (password.length < 11) {
      _showDialog("Error", "Password must be at least 12 characters!");
      return;
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String userId = result.user!.uid;

      // Send verification email
      await result.user!.sendEmailVerification();

      // Add user to Firestore
      await addUser(userId, name, email);

      if (mounted) {
        _showDialog(
            "Success", "Registration successful. Please verify your email.");
      }
    } catch (error) {
      final errorMessage = (error as FirebaseAuthException).message ??
          "An unknown error occurred";
      if (mounted) {
        _showDialog("Error", errorMessage);
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/logo.png',
                height: 200,
              ),
              const SizedBox(height: 16),
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 10),
              _buildTextField(_emailController, 'Email'),
              const SizedBox(height: 10),
              _buildTextField(_passwordController, 'Password',
                  obscureText: true),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(color: Colors.black),
                ),
                onPressed: _validateAndRegister,
                child: const Text('Register',
                    style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
