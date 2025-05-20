import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'assets.dart';
import 'new_contact.dart';
import 'new_chat.dart';

class ChatOptionsModal extends StatelessWidget {
  const ChatOptionsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  static WoltModalSheetPage optionsPage(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      navBarHeight: 20,
      backgroundColor: Colors.white,
      child: SizedBox(
        height: 180, // Fixed height for the modal content
        child: CustomScrollView(
          slivers: [
            SliverList.list(
              children: [
                ListTile(
                  leading: ChatOptionsAssets.commentIcon,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New chat", style: ChatOptionsAssets.titleStyle),
                      Text(
                        "Send a message to your contact",
                        style: ChatOptionsAssets.subtitleStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    WoltModalSheet.of(modalSheetContext).showAtIndex(1);
                  },
                ),
                ListTile(
                  leading: ChatOptionsAssets.profileIcon,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New Contact", style: ChatOptionsAssets.titleStyle),
                      Text(
                        "Add a contact to be able to send messages",
                        style: ChatOptionsAssets.subtitleStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    WoltModalSheet.of(modalSheetContext).showAtIndex(2);
                  },
                ),
                ListTile(
                  leading: ChatOptionsAssets.closeIcon,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Go Back", style: ChatOptionsAssets.titleStyle),
                    ],
                  ),
                  onTap: () => Navigator.of(modalSheetContext).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static WoltModalSheetPage contactSearchPage(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      navBarHeight: 20,
      backgroundColor: Colors.white,
      child: NewContactPage(
        modalSheetContext: modalSheetContext,
        titleStyle: ChatOptionsAssets.titleStyle,
      ),
    );
  }

  static WoltModalSheetPage newChatPage(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      navBarHeight: 20,
      backgroundColor: Colors.white,
      child: NewChatContent(
        modalSheetContext: modalSheetContext,
        titleStyle: ChatOptionsAssets.titleStyle,
      ),
    );
  }
}
