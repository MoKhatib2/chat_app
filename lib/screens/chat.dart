import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.friendUserData});
  final QueryDocumentSnapshot<Map<String, dynamic>> friendUserData;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var _isFetching = true;
  String? _errorMessage;
  String _chatId = '';

  void getChatMessages() async {
    try {
      final currUserId = FirebaseAuth.instance.currentUser!.uid;
      var chatMessages = await firestore
          .collection('chats')
          .doc(currUserId + widget.friendUserData.id)
          .collection('messages')
          .get();

      if (chatMessages.docs.isNotEmpty) {
        _chatId = currUserId + widget.friendUserData.id;
      } else {
        _chatId = widget.friendUserData.id + currUserId;
      }
      setState(() {
        _isFetching = false;
      });
    } on FirebaseException catch (error) {
      setState(() {
        _isFetching = false;
        _errorMessage = error.message;
      });
    }
  }

  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    fcm.subscribeToTopic('chat');
  }

  void _submitMessage(String message) async {
    final currUser = FirebaseAuth.instance.currentUser!;
    final currUserData =
        await firestore.collection('users').doc(currUser.uid).get();

    // final updatedFriendUserData =
    //     await firestore.collection('users').doc(widget.friendUserData.id).get();

    firestore.collection('chats').doc(_chatId).collection('messages').add({
      'text': message,
      'createdAt': Timestamp.now(),
      'userId': currUser.uid,
      'username': currUserData.data()!['username'],
      'userImage': currUserData.data()!['image_url'],
    });
  }

  void _removeFriend() async {
    setState(() {
      _isFetching = true;
    });

    final currUserId = FirebaseAuth.instance.currentUser!.uid;
    final otherUserId = widget.friendUserData.id;

    final currUserData =
        await firestore.collection('users').doc(currUserId).get();

    var newCurrUserFriends = currUserData.get('friends') as List<dynamic>;
    newCurrUserFriends.remove(otherUserId);

    var newOtherUserFriends =
        widget.friendUserData.data()['friends'] as List<dynamic>;
    newOtherUserFriends.remove(currUserId);

    firestore.collection('users').doc(currUserId).update(
      {'friends': newCurrUserFriends},
    );

    firestore.collection('users').doc(otherUserId).update(
      {'friends': newOtherUserFriends},
    );

    setState(() {
      _isFetching = false;
    });

    Navigator.of(context).pop({'friend_removed': true});
  }

  @override
  void initState() {
    super.initState();
    getChatMessages();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ChatMessages(
      chatRoomId: _chatId,
    );

    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      content = Container(
        decoration: const BoxDecoration(color: Colors.red),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error),
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendUserData.data()['username']),
        // backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'Logout') {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              if (value == 'Remove Friend') {
                _removeFriend();
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem<String>(
                  value: 'Remove Friend',
                  child: Row(
                    children: [
                      Text(
                        'Remove Friend',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.red),
                      )
                    ],
                  ),
                ),
                // const PopupMenuItem<String>(
                //   value: 'Logout',
                //   child: Row(
                //     children: [
                //       Text('Logout'),
                //       SizedBox(width: 8),
                //       Icon(Icons.exit_to_app),
                //     ],
                //   ),
                // ),
              ];
            },
            offset: const Offset(0, 30),
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: content),
          NewMessage(
            onSendMessage: _submitMessage,
            sendingDisabled: (_isFetching ||
                (_errorMessage != null && _errorMessage!.isNotEmpty)),
          ),
        ],
      ),
    );
  }
}
