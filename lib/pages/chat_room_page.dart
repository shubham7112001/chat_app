import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    

    if (msg != "") {
      // ChatRoomModel chatRoomModel = ChatRoomModel();
      // Send a message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;

      
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
      ///////////////////////////////////////////
      // Last Updated Time Is Here

      widget.chatroom.lastUpdated = newMessage.createdon;

      FirebaseFirestore.instance
      .collection("chatrooms")
      .doc(widget.chatroom.chatroomid)
      .set(widget.chatroom.toMap());

      log("message sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(
              width: 15,
            ),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(0),
          child: Column(children: [
            // This is where the chats will go

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(9),
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.black54
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    )),
                              ],
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              "An error occured.\nPlease Check Your Internet Connection"),
                        );
                      } else {
                        return const Center(
                          child: Text("Say Hi to your friend!"),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messageController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: "Enter Message"),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(Icons.send,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
