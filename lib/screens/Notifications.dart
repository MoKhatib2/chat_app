import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firestore = FirebaseFirestore.instance;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() {
    return _NotificationsScreenState();
  }
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  var _isLoading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _friendRequestsList = [];

  @override
  void initState() {
    super.initState();
    _getFriendRequests();
  }

  void _getFriendRequests() async {
    final currUserId = FirebaseAuth.instance.currentUser!.uid;
    final currUserData =
        await firestore.collection('users').doc(currUserId).get();
    final allUsers = await firestore.collection('users').get();
    final friendRequests = currUserData.get('friend_requests') as List<dynamic>;

    setState(() {
      _friendRequestsList = allUsers.docs
          .where((user) => friendRequests.contains(user.id))
          .toList();
      _isLoading = false;
    });
  }

  void _accept(String userId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final currUserId = FirebaseAuth.instance.currentUser!.uid;
      final userToAddId = userId;

      final currUserData =
          await firestore.collection('users').doc(currUserId).get();
      final otherUserData =
          await firestore.collection('users').doc(userToAddId).get();

      final currUserFriendsList = currUserData.get('friends') as List<dynamic>;
      final userToAddFriendsList =
          otherUserData.get('friends') as List<dynamic>;

      currUserFriendsList.add(userToAddId);
      userToAddFriendsList.add(currUserId);

      final currUserRequestsList =
          currUserData.get('friend_requests') as List<dynamic>;

      currUserRequestsList.remove(userToAddId);

      await firestore.collection('users').doc(currUserId).update({
        'friends': currUserFriendsList,
        'friend_requests': currUserRequestsList
      });

      await firestore.collection('users').doc(userToAddId).update({
        'friends': userToAddFriendsList,
      });

      // await firestore
      //     .collection('chats')
      //     .doc(currUserId + userToAddId)
      //     .collection('messages')
      //     .add({});

      setState(() {
        _friendRequestsList =
            _friendRequestsList.where((user) => user.id != userId).toList();
        _isLoading = false;
      });
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication faild.'),
        ),
      );

      return;
    }
  }

  void _reject(String userId) async {
    setState(() {
      _isLoading = true;
    });

    final currUserId = FirebaseAuth.instance.currentUser!.uid;
    final currUserData =
        await firestore.collection('users').doc(currUserId).get();

    final currUserRequestsList =
        currUserData.get('friend_requests') as List<dynamic>;

    currUserRequestsList.remove(userId);

    await firestore
        .collection('users')
        .doc(currUserId)
        .update({'friend_requests': currUserRequestsList});

    setState(() {
      _friendRequestsList =
          _friendRequestsList.where((user) => user.id != userId).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: _friendRequestsList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage:
                    NetworkImage(_friendRequestsList[index]['image_url']),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _friendRequestsList[index]['username'],
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text(
                    'Friend Request',
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {
                  _accept(_friendRequestsList[index].id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  'Accept',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  _reject(_friendRequestsList[index].id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text(
                  'Reject',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_friendRequestsList.isEmpty) {
      content = const Center(
        child: Text('You have no notifications.'),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: content);
  }
}
