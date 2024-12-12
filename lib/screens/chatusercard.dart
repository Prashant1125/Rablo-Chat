import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../dialoges/profile_dialog.dart';
import '../helper/my_date_util.dart';
import '../modals/messege.dart';
import '../modals/users.dart';
import 'chatscreen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last messege info (if null messege --> no messege)
  Message? _messege;
  @override
  Widget build(BuildContext context) {
    double mq = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.all(5.0),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => UserScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
          stream: APIs.getLastMesseges(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _messege = list[0];
            }
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDialog(
                                user: widget.user,
                              ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(500),
                      child: CachedNetworkImage(
                        width: mq * 0.15,
                        height: mq * .15,
                        fit: BoxFit.cover,
                        imageUrl: widget.user.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'poppins'),
                        ),
                        //last messege
                        Text(
                            _messege != null
                                ? _messege!.type == Type.image
                                    ? 'Image'
                                    : _messege!.msg
                                : widget.user.about,
                            maxLines: 1),
                      ],
                    ),
                  ),
                  SizedBox(
                      //last messege time
                      child: _messege == null
                          ? null //show nothing when no messege is sent

                          : _messege!.read.isEmpty &&
                                  _messege!.fromid != APIs.user.uid
                              ? Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                      color: Colors.green.shade500,
                                      borderRadius: BorderRadius.circular(10)),
                                )
                              :
                              //messege sent time
                              Text(
                                  MyDateUtil.getLastMessegeTime(
                                      context: context, time: _messege!.sent),
                                  style: const TextStyle(color: Colors.grey),
                                ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
