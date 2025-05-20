import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/providers/chat.provider.dart';
import 'package:tralala_app/core/providers/user.provider.dart';
import 'package:tralala_app/core/utils/time.dart';
import 'package:tralala_app/ui/screens/chat.dart';
import 'package:tralala_app/ui/widgets/shared/profile_picture.dart';

class ChatWidget extends StatefulWidget {
  final Chat chat;

  const ChatWidget({super.key, required this.chat});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    final currentTypingName = context.read<ChatProvider>().getCurrentTypingName(
      widget.chat.id,
    );

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(0),
          elevation: 0,
          child: ListTile(
            minTileHeight: 86,
            tileColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chat: widget.chat),
                ),
              );
            },
            leading: ProfileWidget(
              size: 54,
              online: true,
              imageURL: widget.chat.profileImage,
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(top: 6.0, bottom: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      formatTime(
                        widget.chat.lastMessageTime() ?? DateTime.now(),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (user != null && widget.chat.countUnread(user.id) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 20,
                          height: 20,
                          color: const Color(0xff55C1FF),
                          child: Center(
                            child: Text(
                              widget.chat.countUnread(user.id) < 99
                                  ? widget.chat.countUnread(user.id).toString()
                                  : "99+",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: GoogleFonts.baloo2(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.chat.messages.isNotEmpty)
                  if (currentTypingName != null)
                    Text(
                      "$currentTypingName is typing...",
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    )
                  else
                    Text(
                      widget.chat.messages.first.content,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
