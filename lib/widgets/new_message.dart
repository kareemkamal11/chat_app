import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String messageText = '';
  final messageContoller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    messageContoller.dispose();
  }

  sendMessage() async {
    final message = messageContoller.text;
    if (message.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 100),
          content: const Text('Please enter a message'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }

    FocusScope.of(context).unfocus();
    messageContoller.clear();

    final user = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('chat').add(
      {
        'text': message,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()!['username'],
        'userImage': userData.data()!['image_url'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
        left: 8,
        right: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageContoller,
              decoration: const InputDecoration(
                labelText: 'Send a message...',
              ),
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              onChanged: (value) {
                setState(() {
                  messageText = value;
                });
              },
              keyboardType: TextInputType.text,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
