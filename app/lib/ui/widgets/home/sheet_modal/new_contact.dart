import 'package:flutter/material.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/services/contacts.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class NewContactPage extends StatefulWidget {
  final BuildContext modalSheetContext;
  final TextStyle titleStyle;

  const NewContactPage({
    super.key,
    required this.modalSheetContext,
    required this.titleStyle,
  });

  @override
  State<NewContactPage> createState() => NewContactPageState();
}

class NewContactPageState extends State<NewContactPage> {
  final TextEditingController searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isSearchEmpty = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
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
                    "Add New Contact",
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
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      isSearchEmpty = value.trim().isEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Enter the phone number",
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          "Search for contacts",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Enter a phone number to find contacts",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isSearchEmpty
                          ? null
                          : () async {
                            if (formKey.currentState!.validate()) {
                              final contact = await ContactService.findContact(
                                searchController.text,
                              );

                              print(contact);

                              await DatabaseHelper.instance.insertContact(
                                contact,
                              );

                              WoltModalSheet.of(
                                widget.modalSheetContext,
                              ).showAtIndex(1);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                  child: const Text(
                    "Start chatting",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
