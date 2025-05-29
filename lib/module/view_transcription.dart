import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AES/aes_util.dart';

const fixedKey = 'ThisIsA32ByteFixedKeyForAES1234';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  ViewScreenState createState() => ViewScreenState();
}

class ViewScreenState extends State<ViewScreen> {
  List<Map<String, dynamic>> transcriptions = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTranscriptions();
  }

  Future<void> fetchTranscriptions() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transcriptions')
          .orderBy('timestamp', descending: true)
          .get();

      final fetchedTranscriptions = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'encrypted': doc['transcription'],
          'decrypted': null, // Initially not decrypted
          'isDecrypted': false, // Decryption status
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        transcriptions = fetchedTranscriptions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching transcriptions: $e';
        isLoading = false;
      });
    }
  }

  void toggleDecryption(int index) {
    setState(() {
      // If already decrypted, just toggle visibility
      if (transcriptions[index]['isDecrypted']) {
        transcriptions[index]['isDecrypted'] = false;
        transcriptions[index]['decrypted'] = null;
      } else {
        try {
          // Decrypt the transcription only when needed
          final decryptedText = AESUtil.decryptText(
            transcriptions[index]['encrypted'],
            fixedKey,
          );
          transcriptions[index]['decrypted'] = decryptedText;
          transcriptions[index]['isDecrypted'] = true;
        } catch (e) {
          transcriptions[index]['decrypted'] = 'Decryption failed: $e';
          transcriptions[index]['isDecrypted'] = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Transcriptions'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: transcriptions.length,
                    itemBuilder: (context, index) {
                      final item = transcriptions[index];
                      // Removed unused variable 'isDecrypted'
                      return Card(
                        color: Colors.red[100],
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            item['isDecrypted']
                                ? item['decrypted'] ?? 'Decryption failed'
                                : '[Encrypted]',
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            'Timestamp: ${item['timestamp']}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => toggleDecryption(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              item['isDecrypted'] ? 'Hide' : 'View',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
