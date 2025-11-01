import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/doctor.dart';
import '../../domain/entities/message.dart';

class DoctorChatPage extends StatefulWidget {
  final Doctor doctor;
  const DoctorChatPage({super.key, required this.doctor});

  @override
  State<DoctorChatPage> createState() => _DoctorChatPageState();
}

class _DoctorChatPageState extends State<DoctorChatPage> {
  final _messageCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.doctor.imageUrl)),
            const SizedBox(width: 8),
            Text(widget.doctor.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .doc(widget.doctor.id)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map;
                    final isFromMe = data['isFromDoctor'] == false;
                    return Align(
                      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isFromMe ? Colors.green : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(data['content'], style: TextStyle(color: isFromMe ? Colors.white : Colors.black)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(hintText: "I'm feeling..."),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_messageCtrl.text.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('doctors')
                          .doc(widget.doctor.id)
                          .collection('messages')
                          .add({
                        'content': _messageCtrl.text,
                        'isFromDoctor': false,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      _messageCtrl.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}