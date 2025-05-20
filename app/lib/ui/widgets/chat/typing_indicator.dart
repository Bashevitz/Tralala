import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            height: 32,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: LoadingAnimationWidget.waveDots(
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
