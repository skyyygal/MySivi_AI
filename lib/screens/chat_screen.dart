import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_sivi_ai/models/chat_messages.dart';
import 'package:my_sivi_ai/models/user_models.dart';
import 'package:my_sivi_ai/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  bool isLoading = true;
  final List<String> senderMessages = [
    'Hey!',
    'How are you?',
    'What are you up to?',
    'Tell me something interesting',
    'Any updates',
  ];

  @override
  void initState() {
    super.initState();
    // fetchMessages();
    loadChatConversation();
  }

  Future<void> loadChatConversation() async {
    final random = Random();
    messages.clear();
    try {
      // final apiMessages = await ChatService().fetchReceiverMessagesForUser(
      //   widget.user.id,
      // );

      final apiMessages = await ChatService().fetchReceiverMessages();
      for (int i = 0; i < 5; i++) {
        messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch + i,
            message: senderMessages[random.nextInt(senderMessages.length)],
            senderName: 'You',
            type: MessageType.sender,
          ),
        );
        final msg = apiMessages[i % apiMessages.length];
        messages.add(
          ChatMessage(
            id: msg.id,
            message: msg.message,
            senderName: msg.senderName,
            type: MessageType.receiver,
          ),
        );
      }
      setState(() {
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }
  // Future<void> fetchMessages() async {
  //   try {
  //     final fetchedMessages = await ChatService().fetchReceiverMessages();
  //     setState(() {
  //       messages = fetchedMessages;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.fullName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isSender = msg.type == MessageType.sender;

                return Row(
                  mainAxisAlignment: isSender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isSender) CircleAvatar(child: Text(msg.initials)),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg.message,
                        style: TextStyle(
                          color: isSender ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
