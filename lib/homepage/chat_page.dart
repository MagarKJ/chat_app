import 'dart:io';

import 'package:chat_app/model/message.dart';
import 'package:chat_app/model/user_profile.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/media_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../model/chat.dart';
import '../services/auth_services.dart';
import '../utils/utils.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late MediaService _mediaService;
  ChatUser? currentUser, otherUser;
  late StorageService _storageService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _databaseService = getIt.get<DatabaseService>();
    _mediaService = getIt.get<MediaService>();
    _storageService = getIt.get<StorageService>();
    currentUser = ChatUser(
      id: _authServices.user!.uid,
      firstName: _authServices.user!.displayName,
    );
    otherUser = ChatUser(
      id: widget.chatUser.uid!,
      firstName: widget.chatUser.name,
      profileImage: widget.chatUser.pfpUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          title: Text(widget.chatUser.name!),
        ),
        body: StreamBuilder(
          stream: _databaseService.getChatData(
              uid1: currentUser!.id, uid2: otherUser!.id),
          builder: (context, snapshot) {
            Chat? chat = snapshot.data?.data();
            List<ChatMessage> messages = [];
            if (chat != null && chat.messages != null) {
              messages = _getChatMessagesList(chat.messages!);
            }
            return DashChat(
              messageOptions: const MessageOptions(
                showOtherUsersAvatar: true,
                showTime: true,
              ),
              inputOptions: InputOptions(
                trailing: [_mediaMessageButton()],
                alwaysShowSend: true,
              ),
              currentUser: currentUser!,
              onSend: _sendMessage,
              messages: messages,
            );
          },
        ));
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          messageType: MessageType.image,
          content: chatMessage.medias!.first.url,
          senderID: currentUser!.id,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
          uid1: currentUser!.id,
          uid2: otherUser!.id,
          message: message,
        );
      }
    } else {
      // Send message to the chat
      Message message = Message(
        messageType: MessageType.text,
        content: chatMessage.text,
        senderID: currentUser!.id,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
        uid1: currentUser!.id,
        uid2: otherUser!.id,
        message: message,
      );
    }
  }

  List<ChatMessage> _getChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              type: MediaType.image,
              fileName: '',
            )
          ],
        );
      } else {
        return ChatMessage(
          text: m.content!,
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
      ),
      onPressed: () async {
        File? file = await _mediaService.getImageFromGalary();
        if (file != null) {
          String chatID =
              generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
          String? imageUrl =
              await _storageService.uploadUserPfp(file: file, uid: chatID);
          if (imageUrl != null) {
            ChatMessage chatMessage = ChatMessage(
              createdAt: DateTime.now(),
              user: currentUser!,
              medias: [
                ChatMedia(
                  url: imageUrl,
                  fileName: '',
                  type: MediaType.image,
                )
              ],
            );
            _sendMessage(chatMessage);
          }
        }
      },
    );
  }
}
