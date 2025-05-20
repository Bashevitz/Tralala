import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/data/sockets.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/models/identity.dart';
import 'package:tralala_app/core/models/session.dart';
import 'package:tralala_app/core/providers/chat.provider.dart';
import 'package:tralala_app/core/services/keys.dart';
import 'package:tralala_app/core/utils/X3DH.dart';
import 'package:tralala_app/core/utils/crypto.dart';
import 'package:tralala_app/core/utils/time.dart';
import 'package:tralala_app/core/utils/user.dart';
import 'package:tralala_app/ui/widgets/chat/chat.dart';
import 'package:tralala_app/core/models/message.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      try {
        chatProvider.getChat(widget.chat.id);
      } catch (e) {
        chatProvider.addChat(widget.chat);
      }
    });

    getUserId().then((value) {
      setState(() {
        _userId = value;
        _isLoading = false;
      });
    });
  }

  void _onTyping() {
    // SocketHelper.instance.socket.then((socket) async {
    //   socket.emit("typing:status", {
    //     "chatId": widget.chat.id,
    //     "userId": _userId,
    //     "recipientId":
    //         widget.chat is ContactChat
    //             ? (widget.chat as ContactChat).contact.id
    //             : null,
    //     "isTyping": true,
    //   });
    // });
  }

  void _onStopTyping() {
    // SocketHelper.instance.socket.then((socket) async {
    //   socket.emit("typing:status", {
    //     "chatId": widget.chat.id,
    //     "userId": _userId,
    //     "recipientId":
    //         widget.chat is ContactChat
    //             ? (widget.chat as ContactChat).contact.id
    //             : null,
    //     "isTyping": false,
    //   });
    // });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String message) async {
    final storage = FlutterSecureStorage();
    final identityKeyJson = await storage.read(key: "IdentityKey");
    final identityKey = await Identity.fromJson(jsonDecode(identityKeyJson!));

    final provider = Provider.of<ChatProvider>(context, listen: false);

    final contactChat = widget.chat as ContactChat;
    if (provider.getChat(widget.chat.id) == null) {
      await DatabaseHelper.instance.insertChat(contactChat);
      provider.addChat(widget.chat);
    }

    final messageObj = Message(
      author: _userId!,
      content: message,
      chatId: widget.chat.id,
    );
    final messageJson = messageObj.toJson();

    final session = await DatabaseHelper.instance.fetchSession(widget.chat.id);
    if (session == null) {
      final keyData = await KeyService.retrieveKeys(contactChat.contact.id);
      final encryptedMessage = await X3DH.encryptMessage(keyData, message);

      messageJson['content'] = encryptedMessage['encryptedMessage'];
      messageJson['ephemeralKey'] = encryptedMessage['ephemeralKey'];
      messageJson['identifiers'] = {
        'oneTimePreKey': keyData['oneTimePreKey']['identifier'],
        'signedPreKey': keyData['signedPreKey']['identifier'],
        'identity': await identityKey.getPublicKey(),
      };

      await DatabaseHelper.instance.insertSession(
        Session(
          DateTime.now(),
          chatId: widget.chat.id,
          sharedSecret: encryptedMessage['sharedSecret'],
        ),
      );
    } else {
      messageJson['content'] = await CryptoUtils.encrypt(
        message,
        session.sharedSecret,
      );
    }

    messageJson["recipientId"] =
        widget.chat is ContactChat
            ? (widget.chat as ContactChat).contact.id
            : null;

    await SocketHelper.instance.sendMessage(
      messageJson,
      widget.chat.id,
      contactChat.contact.id,
    );
    await DatabaseHelper.instance.insertMessage(messageObj);

    provider.addMessageForChat(widget.chat.id, messageObj);

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context, listen: false);

    print("Chat name: ${widget.chat.name}");

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: MessageForm(
        onSendMessage: (message) => _sendMessage(message),
        onTyping: _onTyping,
        onStopTyping: _onStopTyping,
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          widget.chat.name,
          style: GoogleFonts.baloo2(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset("assets/icons/arrow_left.svg"),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset("assets/icons/menu_kebab.svg"),
          ),
        ],
      ),
      body: Stack(
        children: [
          const DottedBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white.withOpacity(0.0)],
                stops: const [0.0, 0.3],
              ),
            ),
          ),
          Consumer<ChatProvider>(
            builder: (_, chatProvider, __) {
              try {
                final chat = chatProvider.getChat(widget.chat.id);
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount:
                      (chat?.messages.length ?? 0) +
                      (provider.isContactTyping(widget.chat.id) ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (provider.isContactTyping(widget.chat.id) &&
                        index == 0) {
                      return const TypingIndicator();
                    }
                    final message =
                        chat!.messages[provider.isContactTyping(widget.chat.id)
                            ? index - 1
                            : index];
                    return MessageWidget(
                      name: message.author == _userId ? "Me" : widget.chat.name,
                      message: message.content,
                      time: formatTime(message.createdAt),
                      isContact: message.author != _userId,
                    );
                  },
                );
              } catch (e) {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
