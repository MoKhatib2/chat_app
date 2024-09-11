import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firestore = FirebaseFirestore.instance;

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key, required this.chatRoomId});
  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    if (chatRoomId == '') {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return StreamBuilder(
      stream: firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }

        final chatMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 40,
            left: 13,
            right: 13,
          ),
          reverse: true,
          itemCount: chatMessages.length,
          itemBuilder: (ctx, index) {
            final currentMessage = chatMessages[index];
            final nextMessage = index + 1 < chatMessages.length
                ? chatMessages[index + 1]
                : null;

            final currentMessageUserId = currentMessage['userId'];
            final nextMessageUserId =
                nextMessage == null ? null : nextMessage['userId'];

            if (nextMessageUserId != null &&
                currentMessageUserId == nextMessageUserId) {
              return MessageBubble(
                username: currentMessage['username'],
                message: currentMessage['text'],
                isCurrUser: authenticatedUser.uid == currentMessageUserId,
              );
            }
            return MessageBubble.first(
              username: currentMessage['username'],
              userImage: currentMessage['userImage'],
              message: currentMessage['text'],
              isCurrUser: authenticatedUser.uid == currentMessageUserId,
            );
          },
        );
      },
    );
  }
}
