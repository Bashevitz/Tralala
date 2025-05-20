import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final String time;
  final String name;
  final bool isContact;

  const MessageWidget({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.isContact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isContact ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                gradient:
                    isContact
                        ? null
                        : const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF55C1FF), Color(0xFF00A1FF)],
                        ),
                color: isContact ? Colors.white : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isContact ? 0 : 20),
                  bottomRight: Radius.circular(isContact ? 20 : 0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.baloo2(
                      color: isContact ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: isContact ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isContact ? Colors.grey : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
