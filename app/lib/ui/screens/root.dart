import 'dart:developer';

import 'package:app_bar_with_search_switch/app_bar_with_search_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/data/sockets.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/models/message.dart';
import 'package:tralala_app/core/models/session.dart';
import 'package:tralala_app/core/providers/chat.provider.dart';
import 'package:tralala_app/core/services/contacts.dart';
import 'package:tralala_app/core/services/keys.dart';
import 'package:tralala_app/core/utils/X3DH.dart';
import 'package:tralala_app/core/utils/crypto.dart';
import 'package:tralala_app/ui/screens/home.dart';
import 'package:tralala_app/ui/screens/profile.dart';
import 'package:tralala_app/ui/widgets/home/sheet_modal/options.dart';
import 'package:tralala_app/ui/widgets/home/sheet_modal/assets.dart';
import 'package:tralala_app/ui/widgets/shared/logo.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int activeTab = 0;
  bool _isInitialized = false;

  Future<void> checkKeys() async {
    final keys = await DatabaseHelper.instance.getNumberOfKeys();
    if (keys < 50) {
      await KeyService.registerKeys(setNumber: 100);
      await DatabaseHelper.instance.getNumberOfKeys();
    }
  }

  Future<void> initProviders() async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    final chats = await DatabaseHelper.instance.fetchChats();

    for (final chat in chats) {
      print("Chat ID: ${chat.id}");
      print("Chat Contact id: ${(chat as ContactChat).contact.id}");
      final messages = await DatabaseHelper.instance.fetchChatMessages(chat.id);

      print("Messages: " + messages.length.toString());
      chat.messages = messages;

      provider.addChat(chat);
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkKeys();
    initProviders();

    SocketHelper.instance.subscribe("keys:new", (data) async {
      await KeyService.registerKeys(setNumber: 100);
    });

    SocketHelper.instance.subscribe("message:new", (data) async {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      final chatId = data["chat_id"];

      print("Chat ID: $chatId");
      print(data);

      if (provider.getChat(chatId) == null) {
        final contact = await ContactService.fetchContact(data["author"]);

        final contactChat = ContactChat.fromContact(contact, chatId);
        await DatabaseHelper.instance.insertChat(contactChat);
        provider.addChat(contactChat);
      }

      final session = await DatabaseHelper.instance.fetchSession(chatId);
      if (data["ephemeralKey"] != null && data["identifiers"] != null) {
        final senderBundle = {
          "identifiers": data["identifiers"],
          "ephemeralKey": data["ephemeralKey"],
        };

        final decryptResponse = await X3DH.decryptMessage(
          senderBundle,
          data["content"],
          data["ephemeralKey"],
        );

        if (decryptResponse != "Aborted") {
          final sharedSecret = decryptResponse;
          final messageContent = await CryptoUtils.decrypt(
            data["content"],
            sharedSecret,
          );

          final message = Message(
            id: data["id"],
            content: messageContent,
            author: data["author"],
            chatId: chatId,
            createdAt: DateTime.parse(data["created_at"]),
          );

          provider.addMessageForChat(chatId, message);
          await DatabaseHelper.instance.insertMessage(message);
          await DatabaseHelper.instance.insertSession(
            Session(DateTime.now(), chatId: chatId, sharedSecret: sharedSecret),
          );
        }
      } else if (session != null) {
        data["content"] = await CryptoUtils.decrypt(
          data["content"],
          session.sharedSecret,
        );
        final message = Message.fromJson(data);
        provider.addMessageForChat(chatId, message);
        await DatabaseHelper.instance.insertMessage(message);
      } else {
        return;
      }

      final chat = provider.getChat(chatId);

      if (chat == null) {
        final contact = await ContactService.fetchContact(data["author"]);
        provider.addChat(ContactChat.fromContact(contact, chatId));
        await DatabaseHelper.instance.insertChat(
          ContactChat.fromContact(contact, chatId),
        );
      }
    });

    SocketHelper.instance.subscribe("typing:status", (data) async {
      print("Typing: $data");
      if (data["isTyping"] == true && data["userId"].toString().trim() != "") {
        final contact = await ContactService.fetchContact(data["userId"]);
        final provider = Provider.of<ChatProvider>(context, listen: false);
        provider.setCurrentTypingName(data["chatId"], contact.name);
      } else {
        final provider = Provider.of<ChatProvider>(context, listen: false);
        provider.setCurrentTypingName(data["chatId"], null);
      }
    });

    ChatOptionsAssets.initAssets();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: getFooter(),
      appBar:
          activeTab == 0
              ? AppBarWithSearchSwitch(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                onChanged: (value) {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  chatProvider.searchQuery = value;
                },
                onClosed: () {
                  final chatProvider = Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  );
                  chatProvider.searchQuery = "";
                },
                appBarBuilder: (context) {
                  return AppBar(
                    backgroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    title: const LogoWidget(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF90D6FF), Color(0xFF29B0FE)],
                      ),
                      style: TextStyle(fontSize: 24),
                    ),
                    actions: [
                      IconButton(
                        onPressed:
                            AppBarWithSearchSwitch.of(context)?.startSearch,
                        icon: SvgPicture.asset("assets/icons/search.svg"),
                      ),
                      IconButton(
                        onPressed: () {
                          print("Menu");
                        },
                        icon: SvgPicture.asset("assets/icons/menu.svg"),
                      ),
                    ],
                  );
                },
              )
              : AppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,

                title: Text(
                  "Profile",
                  style: GoogleFonts.baloo2(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      body: getBody(),
    );
  }

  Widget getFooter() {
    return Container(
      height: 96,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x3564646f),
            spreadRadius: 0,
            blurRadius: 29,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  activeTab = 0;
                });
              },
              icon: SvgPicture.asset(
                "assets/icons/home.svg",
                colorFilter: ColorFilter.mode(
                  activeTab == 0 ? Colors.blue[400]! : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.lightBlue.shade200],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton.icon(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: SvgPicture.asset("assets/icons/plus.svg"),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  WoltModalSheet.show<void>(
                    context: context,
                    pageListBuilder: (modalSheetContext) {
                      return [
                        ChatOptionsModal.optionsPage(modalSheetContext),
                        ChatOptionsModal.newChatPage(modalSheetContext),
                        ChatOptionsModal.contactSearchPage(modalSheetContext),
                      ];
                    },
                    modalTypeBuilder: (context) {
                      return WoltModalType.bottomSheet();
                    },
                    onModalDismissedWithBarrierTap: () {
                      debugPrint('Closed modal sheet with barrier tap');
                      Navigator.of(context).pop();
                    },
                  );
                },
                label: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    "New chat",
                    style: GoogleFonts.baloo2(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  activeTab = 1;
                });
              },
              icon: SvgPicture.asset(
                "assets/icons/profile.svg",
                colorFilter: ColorFilter.mode(
                  activeTab == 1 ? Colors.blue[400]! : Colors.grey[400]!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: activeTab,
      children: const [HomeScreen(), ProfileScreen()],
    );
  }
}
