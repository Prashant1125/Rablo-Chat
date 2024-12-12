import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../modals/users.dart';
import '../screens/view_profile.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            // user profile picture
            Positioned(
              top: mq.height * .075,
              left: mq.width * .1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(
                      Icons.person,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ),
            // show user name
            Positioned(
              left: mq.width * .04,
              top: mq.height * .02,
              width: mq.width * .55,
              child: Text(
                user.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),

            // about button
            Positioned(
              right: 8,
              top: 8,
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  shape: const CircleBorder(),
                  minWidth: 0,
                  padding: const EdgeInsets.all(0),
                  child: const Icon(
                    Icons.info_outline,
                    size: 30,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
