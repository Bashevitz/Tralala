import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';

class ProfileWidget extends StatelessWidget {
  final double size;
  final bool? online;
  final String imageURL;
  final Color? outerStrokeColor;
  final bool showOnlineStatus;

  const ProfileWidget({
    super.key,
    required this.size,
    required this.imageURL,
    this.online,
    this.outerStrokeColor,
    this.showOnlineStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: CachedNetworkImage(
        imageUrl: imageURL,
        height: size,
        width: size,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
      ),
    );

    image = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: image,
    );

    if (outerStrokeColor != null) {
      image = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: outerStrokeColor!, width: 3),
        ),
        child: image,
      );
    }

    if (online != null) {
      return badges.Badge(
        badgeContent: const SizedBox(height: 0, width: 0),
        badgeStyle: badges.BadgeStyle(
          badgeColor: const Color(0xff10DC05),
          padding: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white, width: 3),
          elevation: 4,
        ),
        position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
        child: image,
      );
    } else {
      return image;
    }
  }
}
