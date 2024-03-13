import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'An error occurred!',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Messages not found!',
              style: TextStyle(color: Colors.blue[900]),
            ),
          );
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatMessages = chatDocs[index].data();
              final nextMessage = index < chatDocs.length - 1
                  ? chatDocs[index + 1].data()
                  : null;

              final currentMessageUserId = chatMessages['userId'];
              final nextMessageUserId =
                  nextMessage != null ? nextMessage['userId'] : null;

              final bool nextUserIsSame =
                  currentMessageUserId == nextMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessages['text'],
                  isMe: authUser!.uid == chatMessages['userId'],
                );
              } else {
                return MessageBubble.first(
                  message: chatMessages['text'],
                  isMe: authUser!.uid == chatMessages['userId'],
                  userImage: chatMessages['userImage'],
                  username: chatMessages['username'],
                );
              }
            });
      },
    );
  }
}
