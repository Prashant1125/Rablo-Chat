import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../modals/users.dart';
import 'chatusercard.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatUser> list = [];
  final List<ChatUser> _searchlist = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      // resume - Active / online
      // pause - offline
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when tap screen anywhere
      onTap: () => FocusScope.of(context).unfocus(),

      // ignore: deprecated_member_use
      child: WillPopScope(
        //if searchiong is on & back button is pressed then close search
        //else simple close screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 70,
            backgroundColor: Colors.green.withOpacity(0.5),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email.....',
                    ),
                    autofocus: true,
                    style: const TextStyle(
                        fontSize: 18,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w500),
                    onChanged: (val) {
                      //search logic
                      _searchlist.clear();

                      for (var i in list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchlist.add(i);
                        }
                        setState(() {
                          _searchlist;
                        });
                      }
                    },
                  )
                : const Text(
                    'Rablo Chat',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black),
                  ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search_rounded,
                ),
              )
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getAllUser(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                // data is loaded succesfully then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                      itemCount:
                          _isSearching ? _searchlist.length : list.length,
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: _isSearching ? _searchlist[index] : list[index],
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No Connection Found ',
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "times new roman",
                            fontWeight: FontWeight.w800),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
