import 'package:chat_app/screens/Notifications.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/profile.dart';
import 'package:chat_app/widgets/add_friend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firestore = FirebaseFirestore.instance;

class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({super.key});

  @override
  State<FriendsListScreen> createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  List<dynamic> _friendsList = [];
  var _isFetching = true;
  var _numOfNotifications = 0;

  @override
  void initState() {
    super.initState();
    _getFriends();
  }

  _getFriends() async {
    try {
      final allUsers = await firestore.collection('users').get();
      final currUserId = FirebaseAuth.instance.currentUser!.uid;
      final currUserData =
          await firestore.collection('users').doc(currUserId).get();

      if (currUserData.data() == null) {
        setState(() {
          _isFetching = false;
        });
        return;
      }

      final friendsList = allUsers.docs
          .where((user) =>
              (currUserData.get('friends') as List<dynamic>).contains(user.id))
          .toList();

      setState(() {
        _friendsList = friendsList;
        _numOfNotifications =
            (currUserData.get('friend_requests') as List<dynamic>).length;
        _isFetching = false;
      });
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication faild.'),
        ),
      );
    }
  }

  void _addFriend() {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (ctx) => const AddFriend(),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: const Text('My Friends'),
      // backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          onPressed: _addFriend,
          icon: const Icon(Icons.add),
        ),
        Stack(
          children: [
            Positioned(
              right: 10,
              child: Text(
                _numOfNotifications == 0 ? '' : _numOfNotifications.toString(),
                style:
                    const TextStyle(color: Color.fromARGB(255, 250, 170, 49)),
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (ctx) => const NotificationsScreen(),
                      ),
                    )
                    .then((value) => _getFriends());
              },
              icon: const Icon(Icons.notifications),
            ),
          ],
        ),
        PopupMenuButton(
          onSelected: (value) {
            if (value == 'Logout') {
              FirebaseAuth.instance.signOut();
            }
            if (value == 'Profile') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ProfileScreen(),
                ),
              );
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                value: 'Profile',
                child: Row(
                  children: [
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Icon(Icons.person),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'Logout',
                child: Row(
                  children: [
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    const Icon(Icons.exit_to_app),
                  ],
                ),
              ),
            ];
          },
          offset: const Offset(0, 30),
          child: const Icon(Icons.more_vert),
        ),
      ],
    );

    Widget content = ListView.builder(
      itemCount: _friendsList.length,
      itemBuilder: (ctx, index) {
        return Container(
          margin: const EdgeInsets.all(5),
          child: ListTile(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (ctx) =>
                      ChatScreen(friendUserData: _friendsList[index]),
                ),
              )
                  .then((value) {
                if (value['friend_removed']) {
                  setState(() {
                    _friendsList.remove(_friendsList[index]);
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Friend removed successfully'),
                    ),
                  );
                }
              });
            },
            minVerticalPadding: 20,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(_friendsList[index]['image_url']),
            ),
            title: Text(_friendsList[index]['username']),
            style: ListTileStyle.list,
          ),
        );
      },
    );

    if (_friendsList.isEmpty) {
      content = const Center(
        child: Text(
          'You do not have any friends added, try to add a friend by pressing on the add button above.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_isFetching) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
