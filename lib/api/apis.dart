import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../modals/messege.dart';
import '../modals/users.dart';

class APIs {
  // for  Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  //for accessing cloud storage
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  //for Accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;
  // for accessing self information
  static late ChatUser me;
// to return current user
  static User get user => auth.currentUser!;

  // For Accessing firebase Push Notification
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messege token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
      }
    });
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push Notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
          "data": {
            "some_data": "User Id : ${me.id}",
          },
        }
      };
      // ignore: unused_local_variable
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                "key = AAAAUK1EmvQ:APA91bEmDX77T05O8JXT1vjNWkn1GDo_so68iqFxbqIG4plUYmRUc77bHYGVacDLhUVlNm1GIHe87OzVoCzT5XAvuDkeamjGr5vk6f3XnGFqF8DqeA4P0BYB3ptLVRXl7IS205YTedcF"
          },
          body: jsonEncode(body));

      // ignore: empty_catches
    } catch (e) {}
  }

  // for cheaking if ChatUser is exist or not
  static Future<bool> userExist() async {
    return (await firestore.collection('ChatUser').doc(user.uid).get()).exists;
  }

// for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('ChatUser')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
        //for setting user active status
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: 'Hey i am using Bandhan',
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );

    return await firestore
        .collection('ChatUser')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

// for getting all users to firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('ChatUser')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

// for getting spesific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('ChatUser')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

// update online or last active status
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('ChatUser').doc(user.uid).update({
      'name': me.name,
      'email': me.email,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePic(File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});
    me.image = await ref.getDownloadURL();
    await firestore.collection('ChatUser').doc(user.uid).update({
      'image': me.image,
    });
  }

  ///****************Chat Screen related api******
  //chats(collection) --> conversation_id(doc) --> messege(collection)--> messege(doc)

  //useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  ///// for getting all messege of a specific conversation from firestore database

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMesseges(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messeges/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending messeges
  static Future<void> sendMessege(
      ChatUser chatUser, String msg, Type type) async {
    //messege sending time also used as id
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //messege to send
    final Message messege = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        fromid: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationId(chatUser.id)}/messeges/');
    await ref.doc(time).set(messege.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'Image'));
  }

//update read status messege
  static Future<void> updateMessegeReadStatus(Message messege) async {
    firestore
        .collection('chats/${getConversationId(messege.fromid)}/messeges/')
        .doc(messege.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last messsege of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMesseges(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.id)}/messeges/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send Chat Image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;
    final ref = storage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {});
    // updating image in firebase database
    final imageUrl = await ref.getDownloadURL();
    await sendMessege(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.told)}/messeges/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

// Edit Messege
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    firestore
        .collection('chats/${getConversationId(message.told)}/messeges/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
