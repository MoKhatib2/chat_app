import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firestore = FirebaseFirestore.instance;

class AddFriend extends StatefulWidget {
  const AddFriend({super.key});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final _usernameController = TextEditingController();
  var _addingFriend = false;

  void _showSnackBarMessage(String text) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  void _addFriend(username) async {
    FocusScope.of(context).unfocus();
    try {
      _addingFriend = true;
      final allUsers = await firestore.collection('users').get();
      final userToAdd = allUsers.docs
          .where((user) => user.get('username') == username)
          .toList();

      if (userToAdd.isEmpty) {
        _showSnackBarMessage('Could not find a user with this username');
        return;
      }

      final currUserId = FirebaseAuth.instance.currentUser!.uid;
      final userToAddId = userToAdd[0].id;

      if (currUserId == userToAddId) {
        _showSnackBarMessage('Cannot add yourself');
        return;
      }

      final currUserData =
          await firestore.collection('users').doc(currUserId).get();

      if (currUserData.get('username') == username) {
        _showSnackBarMessage('Could not find a user with this username');
        return;
      }

      final currUserFriendsList = currUserData.get('friends') as List<dynamic>;
      if (currUserFriendsList.contains(userToAddId)) {
        _showSnackBarMessage('This user is already your friend');
        return;
      }

      final userToAddRequestsList =
          userToAdd[0].get('friend_requests') as List<dynamic>;

      if (userToAddRequestsList.contains(currUserId)) {
        _showSnackBarMessage('A friend request has already been sent');
        return;
      }

      userToAddRequestsList.add(currUserId);

      await firestore.collection('users').doc(userToAddId).update({
        'friend_requests': userToAddRequestsList,
      });

      // await firestore
      //     .collection('chats')
      //     .doc(currUserId + userToAddId)
      //     .collection('messages')
      //     .add({});

      _addingFriend = false;
      _showSnackBarMessage('A friend Request has been sent successfully');
    } on FirebaseAuthException catch (error) {
      _showSnackBarMessage(error.message ?? 'Authentication faild.');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).viewInsets.bottom + 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              keyboardType: TextInputType.name,
              autocorrect: false,
              decoration: const InputDecoration(
                label: Text('username'),
              ),
            ),
          ),
          if (_addingFriend) const CircularProgressIndicator(),
          if (!_addingFriend)
            TextButton.icon(
              onPressed: () {
                if (_usernameController.value.text.trim().isEmpty) {
                  return;
                }
                _addFriend(_usernameController.value.text.trim());
              },
              label: const Text('Add'),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(),
            ),
        ],
      ),
    );
  }
}
