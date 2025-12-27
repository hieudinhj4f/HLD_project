import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hld_project/feature/auth/presentation/providers/auth_provider.dart';

class DoctorChatListPage extends StatelessWidget {
  const DoctorChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'HLD',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: Colors.green,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userId != null
            ? FirebaseFirestore.instance
                .collection('doctors')
                .doc(userId)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .snapshots()
            : null,
        builder: (context, snapshot) {
          if (userId == null) {
            return const Center(child: Text('Please log in to see your chats'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Get unique patients from messages
          final messages = snapshot.data!.docs;
          final patientIds = <String>{};
          final lastMessages = <String, DocumentSnapshot>{};

          for (var doc in messages) {
            final data = doc.data() as Map<String, dynamic>;
              final senderId = data['senderId'] as String?;
              if (senderId != null && data['isFromDoctor'] == false) {
                patientIds.add(senderId);
                final docData = doc.data() as Map<String, dynamic>?;
                final existingData = lastMessages[senderId]?.data() as Map<String, dynamic>?;
                if (!lastMessages.containsKey(senderId) ||
                    (docData?['timestamp'] != null && 
                     existingData?['timestamp'] != null &&
                     (docData!['timestamp'] as Timestamp).compareTo(existingData!['timestamp'] as Timestamp) > 0)) {
                  lastMessages[senderId] = doc;
                }
              }
          }

          if (patientIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: patientIds.length,
            itemBuilder: (context, index) {
              final patientId = patientIds.elementAt(index);
              final lastMessage = lastMessages[patientId];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(patientId)
                    .get(),
                builder: (context, patientSnapshot) {
                  if (!patientSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final patientData = patientSnapshot.data!.data() as Map<String, dynamic>?;
                  final patientName = patientData?['name'] ?? 'Patient';
                  final messageData = lastMessage?.data() as Map<String, dynamic>?;
                  final messageContent = messageData?['content'] ?? '';
                  final timestamp = messageData?['timestamp'] as Timestamp?;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        patientName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        messageContent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: timestamp != null
                          ? Text(
                              _formatTimestamp(timestamp.toDate()),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            )
                          : null,
                      onTap: () {
                        // Navigate to chat with patient
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DoctorPatientChatPage(
                              patientId: patientId,
                              patientName: patientName,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

// Chat page for doctor to chat with patient
class DoctorPatientChatPage extends StatefulWidget {
  final String patientId;
  final String patientName;

  const DoctorPatientChatPage({
    super.key,
    required this.patientId,
    required this.patientName,
  });

  @override
  State<DoctorPatientChatPage> createState() => _DoctorPatientChatPageState();
}

class _DoctorPatientChatPageState extends State<DoctorPatientChatPage> {
  final _messageCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String doctorId) {
    if (_messageCtrl.text.trim().isEmpty) return;

    FirebaseFirestore.instance
        .collection('doctors')
        .doc(doctorId)
        .collection('messages')
        .add({
      'senderId': widget.patientId,
      'content': _messageCtrl.text.trim(),
      'isFromDoctor': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also add to patient's messages
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .collection('messages')
        .add({
      'doctorId': doctorId,
      'content': _messageCtrl.text.trim(),
      'isFromDoctor': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final doctorId = authProvider.userId;

    if (doctorId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green,
              child: Text(
                widget.patientName.isNotEmpty ? widget.patientName[0].toUpperCase() : 'P',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(widget.patientName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(doctorId)
                  .collection('messages')
                  .where('senderId', isEqualTo: widget.patientId)
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isFromDoctor = data['isFromDoctor'] == true;

                    return Align(
                      alignment: isFromDoctor ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isFromDoctor ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          data['content'] ?? '',
                          style: TextStyle(
                            color: isFromDoctor ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(doctorId),
                  icon: const Icon(Icons.send, color: Colors.green),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.1),
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

