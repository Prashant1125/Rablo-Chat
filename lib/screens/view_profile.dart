// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rabilo/views/constants.dart';

import '../helper/my_date_util.dart';
import '../modals/users.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green.withOpacity(0.5),
          title: Text(
            widget.user.name,
            style: kLabelStyle.copyWith(fontSize: 25),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On - ',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 16),
            ),
            Text(
              MyDateUtil.getLastMessegeTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(500),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'About - ',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16),
                    ),
                    Text(
                      widget.user.about,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
