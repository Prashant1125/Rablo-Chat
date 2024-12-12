// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../home.dart';
import '../modals/users.dart';

class UpdateScreen extends StatefulWidget {
  final ChatUser user;
  const UpdateScreen({super.key, required this.user});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          title: const Text('Update Screen',
              style:
                  TextStyle(fontWeight: FontWeight.w400, color: Colors.black)),
        ),
        body: Form(
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
// profile picture
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(500),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                          //Local image

                          //image From server
                          InkWell(
                              onTap: () {
                                _showBottomSheeet(context);
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(500),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 2,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            _showBottomSheeet(context);
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required field",
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      labelText: 'Display Name',
                      hintText: 'Enter new name',
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .02,
                  ),
                  TextFormField(
                    initialValue: widget.user.email,
                    onSaved: (val) => APIs.me.email = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required field",
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.mail,
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      labelText: 'Email id',
                      hintText: 'Enter new email',
                    ),
                  ),
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : "Required field",
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      prefixIcon: const Icon(
                        Icons.info_outline,
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      labelText: ' About',
                      hintText: 'Eg : feeling Happy',
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          backgroundColor: Colors.green.shade100,
                          minimumSize: Size(mq.height * .1, mq.width * .15)),
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Fluttertoast.showToast(
                                msg: "Profile Update successfully");

                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const HomePage()));
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.save,
                        color: Colors.black,
                      ),
                      label: const Text(
                        'Save Profile',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // for picking a profile picture
  void _showBottomSheeet(BuildContext context) {
    var mq = MediaQuery.of(context).size;

    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (builder) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text(
                'Choose Profile Picture',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: mq.width * .03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePic(File(_image!));

                        // for hiding Botttom Sheet
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        elevation: 0,
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .35, mq.height * .20)),
                    child: const Icon(
                      Icons.image,
                      size: 70,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        APIs.updateProfilePic(File(_image!));
                        // for hiding Botttom Sheet
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        elevation: 0,
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .35, mq.height * .20)),
                    child: const Icon(
                      Icons.photo_camera,
                      size: 70,
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
