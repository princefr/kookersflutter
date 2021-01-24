import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Pages/Messages/FullScreenImage.dart';
import 'package:kookers/Pages/Messages/MessageInput.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Messages/isRead.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:kookers/main.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final Room room;
  final int index;
  ChatPage({Key key, @required this.room, this.index}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends RouteAwareState<ChatPage>
    with AutomaticKeepAliveClientMixin<ChatPage> {
  Future<void> sendMessage(GraphQLClient client, Message message) async {
    final MutationOptions _options = MutationOptions(documentNode: gql(r"""
      mutation SendMEssage($message: MessageInput){
            sendMessage(message: $message)
        }
    """), variables: <String, dynamic>{
      "message": message.toJSON(),
    });

    return await client
        .mutate(_options)
        .then((value) => value.data["sendMessage"]);
  }

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _controller = ScrollController();

// ignore: close_sinks
  final BehaviorSubject<String> messageToSend = BehaviorSubject<String>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      databaseService.getRoom(this.widget.room.id);
      await databaseService.setIschatAreRead(this.widget.room.id);
      await databaseService.loadrooms();
      databaseService.getLastMessage.listen((event) {
        print(" " + "message intente");
      });
    });
    focusNode.addListener(onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear

    }
  }

  void scrollToBottom() {
    _controller.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.bounceIn,
    );
  }

  String subscribeToNewMessage = r"""
      subscription getMEssagedAdded($roomID: ID!)  {
        messageAdded(roomID: $roomID) {
          userId
          message
          createdAt
          message_picture
        }
      }
""";

  final picker = ImagePicker();

  // ignore: close_sinks
  BehaviorSubject<String> pictureToSend = BehaviorSubject<String>();
  // ignore: close_sinks
  BehaviorSubject<File> pictureToPreview = BehaviorSubject<File>();

  Future<File> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    return File(pickedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    final storage = Provider.of<StorageService>(context, listen: true);

    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
          appBar: TopBarChat(
              displayname: this.widget.room.receiver.firstName +
                  " " +
                  this.widget.room.receiver.lastName,
              rightIcon: CupertinoIcons.exclamationmark_circle_fill,
              imageUrl: this.widget.room.receiver.photoUrl,
              height: 54,
              isRightIcon: true,
              onTapRight: () {}),
          body: SafeArea(
            child: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dy > 0) {
                  this.focusNode.unfocus();
                }
              },
              child: Subscription("getMEssagedAdded", subscribeToNewMessage,
                  variables: <String, String>{"roomID": this.widget.room.id},
                  builder: ({dynamic error, bool loading, dynamic payload}) {
                if (payload != null) {
                  // this.widget.room.messages.insert(
                  //     0,
                  //     Message(
                  //         createdAt: payload["messageAdded"]["createdAt"],
                  //         userId: payload["messageAdded"]["userId"],
                  //         message: payload["messageAdded"]["message"],
                  //         isRead: false,
                  //         isSent: true));
                  // this.scrollToBottom();
                }

                return Stack(
                  children: [
                    Column(children: [
                      Expanded(
                          child: StreamBuilder<List<Message>>(
                              stream: databaseService.messagesInRoom.stream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  return LinearProgressIndicator();
                                if (snapshot.hasError)
                                  return Text("i've a bad felling");
                                if (snapshot.data.isEmpty)
                                  return Text("its empty out there");
                                return ListView.builder(
                                    reverse: true,
                                    shrinkWrap: true,
                                    controller: _controller,
                                    itemCount: snapshot.data.length,
                                    itemBuilder: (context, index) {
                                      if (snapshot.data[index].userId ==
                                          databaseService.user.value.id) {
                                        return ListTile(
                                            title: Column(
                                          children: [
                                            ChatBubble(
                                              elevation: 0,
                                              shadowColor: Colors.white,
                                              alignment: Alignment.topRight,
                                              margin: EdgeInsets.only(top: 20),
                                              clipper: ChatBubbleClipper5(
                                                  type: BubbleType.sendBubble),
                                              child: Column(
                                                children: [
                                                  Container(
                                                      constraints:
                                                          BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                      ),
                                                      child: Text(
                                                        snapshot.data[index]
                                                            .message,
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color: Colors
                                                                    .white),
                                                      )),
                                                  SizedBox(height: 10),
                                                  Builder(builder: (ctx) {
                                                    if (snapshot.data[index]
                                                                .messagePicture ==
                                                            "" ||
                                                        snapshot.data[index]
                                                                .messagePicture ==
                                                            null)
                                                      return SizedBox();
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            CupertinoPageRoute(
                                                                builder: (context) => FullScreenImage(
                                                                    url: snapshot
                                                                        .data[
                                                                            index]
                                                                        .messagePicture)));
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[
                                                                200],
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                            image: DecorationImage(
                                                                image: CachedNetworkImageProvider(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .messagePicture),
                                                                fit: BoxFit
                                                                    .cover,
                                                                alignment:
                                                                    Alignment
                                                                        .center)),
                                                        height: 150,
                                                      ),
                                                    );
                                                  })
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    snapshot
                                                        .data[index].createdAt,
                                                    style:
                                                        GoogleFonts.montserrat(
                                                            fontSize: 11),
                                                  ),
                                                  SizedBox(width: 10),
                                                  IsReadWidget(
                                                    isRead: snapshot
                                                        .data[index].isRead,
                                                    isSent: snapshot
                                                        .data[index].isSent,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ));
                                      } else {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: ListTile(
                                              leading: CircleAvatar(
                                                radius: 20,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                        this
                                                            .widget
                                                            .room
                                                            .receiver
                                                            .photoUrl),
                                              ),
                                              title: Column(
                                                children: [
                                                  ChatBubble(
                                                    elevation: 0,
                                                    alignment:
                                                        Alignment.topLeft,
                                                    backGroundColor:
                                                        Colors.grey[300],
                                                    shadowColor: Colors.white,
                                                    clipper: ChatBubbleClipper5(
                                                        type: BubbleType
                                                            .receiverBubble),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            constraints:
                                                                BoxConstraints(
                                                              maxWidth: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.7,
                                                            ),
                                                            child: Text(
                                                                snapshot
                                                                    .data[index]
                                                                    .message,
                                                                style: GoogleFonts
                                                                    .montserrat(
                                                                        color: Colors
                                                                            .black))),
                                                        SizedBox(height: 10),
                                                        Builder(builder: (ctx) {
                                                          if (snapshot
                                                                      .data[
                                                                          index]
                                                                      .messagePicture ==
                                                                  "" ||
                                                              snapshot
                                                                      .data[
                                                                          index]
                                                                      .messagePicture ==
                                                                  null)
                                                            return SizedBox();
                                                          return InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  CupertinoPageRoute(
                                                                      builder: (context) => FullScreenImage(
                                                                          url: snapshot
                                                                              .data[index]
                                                                              .messagePicture)));
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10.0)),
                                                                  image: DecorationImage(
                                                                      image: CachedNetworkImageProvider(snapshot
                                                                          .data[
                                                                              index]
                                                                          .messagePicture),
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      alignment:
                                                                          Alignment
                                                                              .center)),
                                                              height: 150,
                                                            ),
                                                          );
                                                        })
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "date d'envoie",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                fontSize: 11),
                                                      ))
                                                ],
                                              )),
                                        );
                                      }
                                    });
                              })),
                      MessageInput(
                        image: this.pictureToPreview,
                        textEditingController: this.textEditingController,
                        message: messageToSend,
                        focusNode: this.focusNode,
                        animationDuration: Duration(milliseconds: 300),
                        onSubmitted: (String message) {
                          print("the message has been submitted");
                        },
                        onAttachmentCiclked: () {
                          getImage().then((file) {
                            this.pictureToPreview.sink.add(file);
                          });
                        },
                        onSendingClicked: () async {
                          this.textEditingController.text = "";
                          Message message = Message(
                              createdAt: DateTime.now().toIso8601String(),
                              message: this.messageToSend.value,
                              isRead: false,
                              isSent: false,
                              userId: databaseService.user.value.id,
                              messagePicture: pictureToPreview.value != null
                                  ? await storage.uploadPictureFile(
                                      databaseService.user.value.id,
                                      "messages/" + Uuid().v1(),
                                      this.pictureToPreview.value)
                                  : "",
                              roomId: this.widget.room.id,
                              receiverPushToken:
                                  this.widget.room.receiver.notificationToken);
                          databaseService.updateSingleRoom(
                              this.widget.room.id, message);
                          this.messageToSend.sink.add(null);
                          this.pictureToPreview.sink.add(null);
                          await this.sendMessage(client, message);
                          await databaseService.loadrooms();
                        },
                      )
                    ])
                  ],
                );
              }),
            ),
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
