import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MessageForm extends StatefulWidget {
  final Function(String) onSendMessage;

  final Function onTyping;
  final Function onStopTyping;

  const MessageForm({
    super.key,
    required this.onSendMessage,
    required this.onTyping,
    required this.onStopTyping,
  });

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasInput = false;
  Timer? _typingTimer;
  bool _isTyping = false;

  void _onTextChanged() {
    setState(() {
      _hasInput = _messageController.text.trim().isNotEmpty;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    widget.onSendMessage(_messageController.text);
    setState(() {
      _hasInput = false;
      _messageController.clear();
    });
  }

  void _runTimer() {
    if (_typingTimer != null && _typingTimer!.isActive) _typingTimer!.cancel();
    _typingTimer = Timer(Duration(milliseconds: 600), () {
      if (!_isTyping) return;
      _isTyping = false;
      widget.onStopTyping();
    });
    _isTyping = true;
    widget.onTyping();
  }

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_runTimer);
  }

  @override
  void dispose() {
    _messageController.removeListener(_runTimer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 3,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.05),
            ),
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 2,
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.0,
            top: 8.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          onChanged: (_) {
                            _onTextChanged();
                            _runTimer();
                          },
                          onSubmitted: (_) {
                            _sendMessage();
                          },
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 44,
                        width: 44,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _hasInput ? _sendMessage : () {},
                          icon: SvgPicture.asset(
                            _hasInput
                                ? "assets/icons/send.svg"
                                : "assets/icons/microphone.svg",
                            height: 24,
                            width: 24,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
