import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/providers/chat.provider.dart';
import 'package:tralala_app/ui/widgets/home/chat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder:
          (_, chatProvider, __) =>
              chatProvider.allChats.isEmpty
                  ? SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: chatProvider.filteredChats.length,
                    itemBuilder: (context, index) {
                      final chat = chatProvider.filteredChats[index];
                      return ChatWidget(chat: chat);
                    },
                  ),
    );
  }
}
