import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kookers/Pages/Messages/MessageInput.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Messages/SwipeableCell.dart';
import 'package:kookers/Pages/Messages/chat_image_message.dart';
import 'package:kookers/Pages/Messages/date_below_message.dart';
import 'package:kookers/Pages/Messages/isRead.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Services/StorageService.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final Room room;
  final int? index;
  final uid;
  ChatPage({Key? key, required this.room, this.index, this.uid})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {




  StreamSubscription<void>? streamNewMessage;
  StreamSubscription<dynamic>? streamHasRead;
  StreamSubscription<void>? streamIsWriting;

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final _controller = ScrollController();

// ignore: close_sinks
  final BehaviorSubject<String> messageToSend = BehaviorSubject<String>();
  // ignore: close_sinks
  final BehaviorSubject<List<Message>> messages =
      BehaviorSubject<List<Message>>();
  StreamSubscription<Room>? roomSubscription;

  StreamSubscription<Message?> get unreadMessage => messages
      .map((event) {
        try {
          return event.lastWhere(
              (message) =>
                  (message.userId != this.widget.uid && message.isRead == false));
        } catch (e) {
          return null;
        }
      })
      .listen((event) => event);

  // ignore: unused_field
  bool _active = false;

  @override
  void initState() {
    this._active = true;
    Future.delayed(Duration.zero, () async {
      final databaseService =
          Provider.of<DatabaseProviderService>(context, listen: false);
      this.roomSubscription =
          databaseService.getRoom(this.widget.room.id, this.messages);
      this.streamNewMessage =
          databaseService.newMessageStream(this.widget.room.id);
      this.streamHasRead =
          databaseService.messageReadStream(this.widget.room.id);
      this.streamIsWriting =
          databaseService.userIsWritingStream(this.widget.room.id);
      this.unreadMessage?.onData((data) {
        if (data != null) {
          databaseService.setIschatAreRead(this.widget.room.id);
          databaseService.loadrooms();
        }
      });
      this.streamHasRead?.onData((data) {
        databaseService.loadrooms();
      });

      this.streamNewMessage?.onData((data) {
        databaseService.loadrooms();
      });
    });
    focusNode.addListener(onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    this.streamNewMessage?.cancel();
    this.streamHasRead?.cancel();
    this.streamIsWriting?.cancel();
    this.messages.close();
    this.unreadMessage.cancel();
    this._active = false;
    this._controller.dispose();
    this.messageToSend.close();
    this.roomSubscription?.cancel();
    super.dispose();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear

    }
  }

  final picker = ImagePicker();

  // ignore: close_sinks
  BehaviorSubject<String> pictureToSend = BehaviorSubject<String>();

  // ignore: close_sinks
  BehaviorSubject<File?> pictureToPreview = BehaviorSubject<File?>();

  Future<File?> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: true);
    final storage = Provider.of<StorageService>(context, listen: true);

    return Scaffold(
        appBar: TopBarChat(
            displayname: (this.widget.room.receiver?.firstName ?? "") +
                " " +
                (this.widget.room.receiver?.lastName ?? ""),
            rightIcon: CupertinoIcons.exclamationmark_circle_fill,
            imageUrl: this.widget.room.receiver?.photoUrl,
            height: 54,
            isRightIcon: false,
            onTapRight: () {}),
        body: SafeArea(
          child: Stack(
            children: [
              Column(children: [
                Expanded(
                    child: StreamBuilder<List<Message>>(
                        stream: this.messages.stream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return LinearProgressIndicator(
                                backgroundColor: Colors.black,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white));
                          if (snapshot.hasError)
                            return Text(
                              "Une erreur s'est produite",
                              style: GoogleFonts.montserrat(),
                            );
                          if (snapshot.data?.isEmpty ?? true)
                            return EmptyViewElse(
                                text: "Vous n'avez aucun messages");
                          return Scrollbar(
                            child: ListView.builder(
                                reverse: true,
                                shrinkWrap: true,
                                controller: _controller,
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  if (snapshot.data![index].userId ==
                                      databaseService.user.value?.id) {
                                    return ListTile(
                                        autofocus: false,
                                        title: Column(
                                          children: [
                                            ChatImageMessage(
                                                messagePicture: snapshot
                                                    .data![index]
                                                    .messagePicture ?? ''),
                                            SizedBox(height: 5),
                                            new ChatBubble(
                                              elevation: 0,
                                              shadowColor: Colors.white,
                                              alignment: Alignment.topRight,
                                              margin: EdgeInsets.only(top: 5),
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
                                                        snapshot.data![index]
                                                            .message ?? "",
                                                        style: GoogleFonts
                                                            .montserrat(
                                                                color: Colors
                                                                    .white),
                                                      )),
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
                                                  DateBelowMessage(
                                                      date: snapshot.data![index]
                                                          .createdAt ?? ''),
                                                  SizedBox(width: 10),
                                                  IsReadWidget(
                                                    isRead: snapshot
                                                        .data![index].isRead ?? false,
                                                    isSent: snapshot
                                                        .data![index].isSent ?? false,
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ));
                                  } else {
                                    return SwipeableCell(
                                      onSwipeEnd: () {
                                        FocusScope.of(context).unfocus();
                                      },
                                      backgroundIcon: Icon(CupertinoIcons
                                          .arrowshape_turn_up_left),
                                      child: ListTile(
                                          onLongPress: (){
                                            print("long pressed");
                                          },
                                          autofocus: false,
                                          title: Column(
                                            children: [
                                              ChatImageMessage(
                                                  messagePicture: snapshot
                                                      .data![index]
                                                      .messagePicture ?? ''),
                                              SizedBox(height: 5),
                                              new ChatBubble(
                                                elevation: 0,
                                                alignment: Alignment.topLeft,
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
                                                            snapshot.data![index]
                                                                .message ?? "",
                                                            style: GoogleFonts
                                                                .montserrat(
                                                                    color: Colors
                                                                        .black))),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: DateBelowMessage(
                                                    date: snapshot
                                                        .data![index].createdAt ?? '',
                                                  ))
                                            ],
                                          )),
                                    );
                                  }
                                }),
                          );
                        })),
                MessageInput(
                  image: this.pictureToPreview as BehaviorSubject<File>?,
                  textEditingController: this.textEditingController,
                  message: messageToSend,
                  focusNode: this.focusNode,
                  animationDuration: Duration(milliseconds: 300),
                  onAttachmentCiclked: () async {
                    final status = await Permission.photos.status;
                    print(status);
                    if(status.isDenied){
                      showDialog(context: context, builder: (BuildContext ctx){
                                     return CupertinoAlertDialog(
                                        title: Text("Accès à la biblioteque et photos"),
                                        content: Center(child: Text("Vous avez refusé la permission de prendre les photos, veuillez changer les permissions dans les paramètres de votre téléphone."),),
                                        actions: [
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Continuer', style: TextStyle(color:Colors.red),),
                                          ),

                                          CupertinoDialogAction(
                                            onPressed: () {
                                              openAppSettings();
                                            },
                                            isDefaultAction: true,
                                            child: const Text('Paramètres'),
                                          )
                                        ],
                                      );
                                   });
                    }else{
                      getImage().then((file) async {
                        if(file != null) {
                          FlutterNativeImage.compressImage(file.path, quality: 35)
                              .then((compressed) {
                            this.pictureToPreview.sink.add(compressed);
                          });
                        }
                      });
                    }
                  
                  },

                  onSendingClicked: () async {
                    this.textEditingController.text = "";
                    Message message = Message(
                        createdAt: DateTime.now().toIso8601String(),
                        message: this.messageToSend.value,
                        isRead: false,
                        isSent: false,
                        userId: databaseService.user.value?.id ?? '',
                        messagePicture: (pictureToPreview.value != null && this.pictureToPreview.value != null)
                            ? await storage.uploadPictureFile(
                                databaseService.user.value?.id ?? "",
                                "messages/" + Uuid().v1(),
                                this.pictureToPreview.value!,
                                "message")
                            : "",
                        roomId: this.widget.room.id,
                        receiverPushToken:
                            this.widget.room.receiver?.notificationToken, client: databaseService.client);
                    databaseService.updateSingleRoom(
                        this.widget.room.id, message);
                    this.messageToSend.sink.add("");
                    this.pictureToPreview.sink.add(null);
                    await message.send();
                  },
                )
              ])
            ],
          ),
        ));
  }
}
