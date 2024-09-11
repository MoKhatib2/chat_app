import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.username,
    required this.message,
    required this.isCurrUser,
  })  : userImage = null,
        isFirstMessage = false;

  const MessageBubble.first({
    super.key,
    required this.username,
    required this.userImage,
    required this.message,
    required this.isCurrUser,
  }) : isFirstMessage = true;

  final String username;
  final String? userImage;
  final String message;
  final bool isCurrUser;
  final bool isFirstMessage;

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isFirstMessage)
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(userImage!),
          ),
        if (!isFirstMessage) const SizedBox(width: 36),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirstMessage)
              Text(
                username,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  bottomRight: const Radius.circular(10),
                  bottomLeft: const Radius.circular(10),
                  topLeft: isFirstMessage
                      ? const Radius.circular(0)
                      : const Radius.circular(10),
                ),
              ),
              constraints: BoxConstraints.loose(const Size.fromWidth(200)),
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ],
    );

    if (isCurrUser) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isFirstMessage)
                Text(
                  username,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 158, 185, 199),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(10),
                    bottomRight: const Radius.circular(10),
                    bottomLeft: const Radius.circular(10),
                    topRight: isFirstMessage
                        ? const Radius.circular(0)
                        : const Radius.circular(10),
                  ),
                ),
                constraints: BoxConstraints.loose(const Size.fromWidth(200)),
                child: Text(
                  message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          if (isFirstMessage)
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(userImage!),
            ),
          if (!isFirstMessage) const SizedBox(width: 36),
        ],
      );
    }

    return Container(
      margin: isFirstMessage
          ? const EdgeInsets.only(top: 12)
          : const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: content,
    );
  }
}
