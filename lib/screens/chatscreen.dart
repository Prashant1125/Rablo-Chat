import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../modals/messege.dart';
import '../modals/users.dart';
import 'messege_card.dart';
import 'view_profile.dart';

class UserScreen extends StatefulWidget {
  final ChatUser user;
  const UserScreen({super.key, required this.user});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
//for storing all messeges
  List<Message> _list = [];
// for handling messege text change
  final _textController = TextEditingController();

  // for storing value for showing or hiding emoji emoji
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: () {
          if (_showEmoji) {
            setState(() {
              _showEmoji = !_showEmoji;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 216, 227, 236),
          appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: Colors.green.withOpacity(0.5),
            elevation: 10,
            automaticallyImplyLeading: false,
            leading: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            titleSpacing: 0,
            title: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ViewProfileScreen(user: widget.user)));
                },
                child: StreamBuilder(
                  stream: APIs.getUserInfo(widget.user),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.docs;
                    final list = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: CachedNetworkImage(
                              width: mq.height * .07,
                              height: mq.height * .07,
                              fit: BoxFit.cover,
                              imageUrl: list.isNotEmpty
                                  ? list[0].image
                                  : widget.user.image,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // for user name
                              Text(
                                list.isNotEmpty
                                    ? list[0].name
                                    : widget.user.name,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                              // for adding space
                              const SizedBox(
                                height: 1,
                              ),
                              // last seen of user
                              Text(
                                  list.isNotEmpty
                                      ? list[0].isOnline
                                          ? 'Online'
                                          : MyDateUtil.getLastActiveTime(
                                              context: context,
                                              lastActive: list[0].lastActive)
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive: widget.user.lastActive),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMesseges(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      // if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      // data is loaded succesfully then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            padding: EdgeInsets.only(top: mq.height * .01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return MessageCard(
                                message: _list[index],
                              );
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Say Hi 👋',
                              style: TextStyle(
                                  fontSize: 23, color: Colors.blueGrey),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              //progress indicator for showing uploading
              if (_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  ),
                ),
              //chat input field
              _chatInput(),
              // show emoji on keyboard
              if (_showEmoji == true)
                SizedBox(
                  height: mq.height * .50,
                  child: EmojiPicker(
                    textEditingController: _textController,
                    config: const Config(
                      height: 260,
                    ),
                  ),
                ),
              SizedBox(
                height: mq.height * .05,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatInput() {
    var mq = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * 0.025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _showEmoji = !_showEmoji);
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueGrey,
                        size: 26,
                      )),
                  // text field
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    style: const TextStyle(fontSize: 18),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Type Something ...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none),
                  )),
                  // pick image from gallery
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// picking multiple image
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
// uploading and send image one by one
                        for (var i in images) {
                          setState(() => _isUploading = true);

                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueGrey,
                        size: 26,
                      )),
                  //pick image from camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueGrey, size: 26)),
                  const SizedBox(
                    width: .02,
                  ),
                ],
              ),
            ),
          ),

          //Send Messege Button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessege(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            shape: const CircleBorder(),
            color: const Color.fromARGB(255, 53, 142, 56),
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 5),
            minWidth: 0,
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
