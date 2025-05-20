import 'package:flutter/material.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/models/contact.dart';
import 'package:tralala_app/ui/screens/chat.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class NewChatContent extends StatefulWidget {
  final BuildContext modalSheetContext;
  final TextStyle titleStyle;

  const NewChatContent({
    super.key,
    required this.modalSheetContext,
    required this.titleStyle,
  });

  @override
  State<NewChatContent> createState() => _NewChatContentState();
}

class _NewChatContentState extends State<NewChatContent> {
  final TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  List<Contact> _contacts = [];
  bool _isLoading = true;

  Future<void> fetchContacts() async {
    setState(() {
      _isLoading = true;
    });
    _contacts = await DatabaseHelper.instance.fetchContacts();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  List<Contact> get filteredContacts {
    if (isSearchEmpty) return _contacts;
    final query = searchController.text.toLowerCase();
    return _contacts.where((contact) {
      return contact.name.toLowerCase().contains(query) ||
          contact.phoneNumber.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed:
                      () => WoltModalSheet.of(
                        widget.modalSheetContext,
                      ).showAtIndex(0),
                ),
                const SizedBox(width: 8),
                Text(
                  "New Chat",
                  style: widget.titleStyle.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    isSearchEmpty = value.trim().isEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search contacts",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child:
                  _isLoading
                      ? Container()
                      : filteredContacts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No contacts found",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Try a different search term",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                contact.profileImage,
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              contact.phoneNumber,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              // TODO: Implement start chat functionality
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatScreen(
                                        chat: ContactChat.fromContact(
                                          contact,
                                          null,
                                        ),
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
