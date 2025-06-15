import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AES/aes_util.dart';

const fixedKey = 'ThisIsA32ByteFixedKeyForAES1234';

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

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  ViewScreenState createState() => ViewScreenState();
}

class ViewScreenState extends State<ViewScreen> {
  List<Map<String, dynamic>> transcriptions = [];
  Set<String> selectedIds = {};
  bool isLoading = true;
  String errorMessage = '';

  double progressValue = 0.0;
  String progressLabel = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchTranscriptions();
  }

  Future<void> fetchTranscriptions() async {
    try {
      setState(() {
        progressValue = 0.3;
        progressLabel = 'Fetching user...';
      });

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() {
        progressValue = 0.6;
        progressLabel = 'Querying Firestore...';
      });

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
          'decrypted': null,
          'isDecrypted': false,
          'timestamp': (doc['timestamp'] as Timestamp).toDate(),
        };
      }).toList();

      setState(() {
        transcriptions = fetchedTranscriptions;
        progressValue = 1.0;
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
      for (int i = 0; i < transcriptions.length; i++) {
        if (i == index) {
          if (transcriptions[i]['isDecrypted']) {
            transcriptions[i]['isDecrypted'] = false;
            transcriptions[i]['decrypted'] = null;
          } else {
            try {
              final decryptedText = AESUtil.decryptText(
                transcriptions[i]['encrypted'],
                fixedKey,
              );
              transcriptions[i]['decrypted'] = decryptedText;
              transcriptions[i]['isDecrypted'] = true;
            } catch (e) {
              transcriptions[i]['decrypted'] = 'Decryption failed: $e';
              transcriptions[i]['isDecrypted'] = true;
            }
          }
        } else {
          transcriptions[i]['isDecrypted'] = false;
          transcriptions[i]['decrypted'] = null;
        }
      }
    });
  }

  void handleLongPress(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  void handleTap(String id, int index) {
    if (selectedIds.isNotEmpty) {
      handleLongPress(id);
    } else {
      toggleDecryption(index);
    }
  }

  void clearSelection() {
    setState(() => selectedIds.clear());
  }

  void deleteSelected() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    for (var id in selectedIds) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transcriptions')
          .doc(id)
          .delete();
    }
    fetchTranscriptions();
    clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: selectedIds.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: clearSelection,
              )
            : null,
        title: Text(selectedIds.isNotEmpty
            ? '${selectedIds.length} selected'
            : 'View Transcriptions'),
        actions: selectedIds.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedIds =
                          transcriptions.map((e) => e['id'] as String).toSet();
                    });
                  },
                  child: const Text('Select all',
                      style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
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
      body: isLoading
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
                      label: progressLabel,
                      progress: progressValue,
                    ),
                  ],
                ),
              ),
            )
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
                  itemCount: transcriptions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: Colors.yellow[100],
                        child: const Text(
                          "💡 Swipe left/right to delete.",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }

                    final item = transcriptions[index - 1];
                    final id = item['id'] as String;
                    final isSelected = selectedIds.contains(id);

                    return Dismissible(
                      key: Key(id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text(
                                'Are you sure you want to delete this transcription?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .collection('transcriptions')
                              .doc(id)
                              .delete();
                        }
                        setState(() {
                          transcriptions.removeAt(index - 1);
                        });
                      },
                      child: Card(
                        color:
                            isSelected ? Colors.red[200] : Colors.red[100],
                        margin:
                            const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          onTap: () => handleTap(id, index - 1),
                          title: Text(
                            item['isDecrypted']
                                ? item['decrypted'] ?? 'Decryption failed'
                                : '[Encrypted]',
                            style: const TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                              'Timestamp: ${item['timestamp']}'),
                          trailing: selectedIds.isEmpty
                              ? ElevatedButton(
                                  onPressed: () =>
                                      toggleDecryption(index - 1),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(item['isDecrypted']
                                      ? 'Hide'
                                      : 'View'),
                                )
                              : Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => handleLongPress(id),
                                ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: selectedIds.isNotEmpty
          ? BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.share), label: 'Share'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.edit), label: 'Rename'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.delete), label: 'Delete'),
              ],
              onTap: (index) {
                if (index == 2) deleteSelected();
                // Add share and rename functionality here.
              },
            )
          : null,
    );
  }
}
