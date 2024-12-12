import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rabilo/helper/dialoge.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../api/apis.dart';
import '../modals/users.dart';
import '../views/login.dart';
import 'update.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChatUser> list = [];

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message) {
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    double mq = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.green.withOpacity(0.5),
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 10, bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: () async {
            //for showing progress dialog
            Dialogs.showProgressBar(context);

            await APIs.updateActiveStatus(false);

            //sign out from app
            await APIs.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                //for hiding progress dialog
                Navigator.pop(context);

                //for moving to home screen
                APIs.auth = FirebaseAuth.instance;

                //replacing home screen with login screen
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
            });
          },
          icon: const Icon(
            Icons.logout_rounded,
          ),
          label: const Text(
            'Logout',
            style: TextStyle(fontSize: 15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq * .05),
          child: Column(
            children: [
              SizedBox(
                width: mq,
                height: mq * .1,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(500),
                child: WidgetZoom(
                  heroAnimationTag: 'tag',
                  zoomWidget: CachedNetworkImage(
                    width: mq * .4,
                    height: mq * .4,
                    fit: BoxFit.cover,
                    imageUrl: APIs.me.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(
                        Icons.person,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: mq * .05,
              ),
              Text(
                APIs.me.name,
                maxLines: 2,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent),
              ),
              Text(
                APIs.me.id,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 15),
              ),
              SizedBox(
                height: mq * .05,
              ),
              Container(
                padding: const EdgeInsets.only(left: 5, right: 5),
                color: Colors.grey.shade300,
                child: Card(
                  elevation: 5,
                  color: Colors.white,
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Text(
                            'Name: ',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          title: Text(
                            APIs.me.name,
                            style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          titleAlignment: ListTileTitleAlignment.titleHeight,
                        ),
                        ListTile(
                          leading: const Text(
                            'Email Id: ',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          title: Text(
                            APIs.me.email,
                            style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          titleAlignment: ListTileTitleAlignment.titleHeight,
                        ),
                        ListTile(
                          leading: const Text(
                            'About: ',
                            style: TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          title: Text(
                            APIs.me.about,
                            style: const TextStyle(
                                fontSize: 17,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          titleAlignment: ListTileTitleAlignment.titleHeight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: Colors.green.shade100,
                      minimumSize: Size(mq * .5, mq * .15)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UpdateScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
                  label: const Text(
                    'Edit Profile',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
