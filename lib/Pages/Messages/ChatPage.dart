

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/Messages/MessageInput.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Pages/Messages/isRead.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';



class ChatPage extends StatefulWidget {
  final Room room;
  ChatPage({Key key,@required this.room}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {



Future<void> sendMessage(String message, String roomId, String userId, GraphQLClient client) async{
  final MutationOptions _options  = MutationOptions(
    documentNode: gql(r"""
      mutation SendMEssage($message: String!, $roomId: ID!, $userId: String!, $createdAt: String!){
            sendMessage(message: {message: $message, roomId: $roomId, userId: $userId, createdAt: $createdAt})
        }
    """),
    variables:  <String, String> {
      "message": message,
      "roomId": roomId,
      "userId": userId,
      "createdAt": DateTime.now().toIso8601String()
    }
  );

  return await client.mutate(_options).then((value) => value.data["sendMessage"]);
}




final TextEditingController textEditingController = TextEditingController();
final FocusNode focusNode = FocusNode();
final _controller = ScrollController();

// ignore: close_sinks
final BehaviorSubject<String> messageToSend = BehaviorSubject<String>();

  int _limit = 20;
  final int _limitIncrement = 20;

  _scrollListener() {
    if (_controller.offset >=
            _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        this._limit += this._limitIncrement;
      });
    }
    if (_controller.offset <=
            _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

@override
  void initState(){
    focusNode.addListener(onFocusChange);
    _controller.addListener(_scrollListener);
    super.initState();
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

@override
  void dispose() {
    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseProviderService>(context, listen: true);
    
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
        appBar: TopBarChat(displayname: this.widget.room.receiver.firstName + " " + this.widget.room.receiver.lastName, rightIcon: CupertinoIcons.exclamationmark_circle_fill,
        height: 54,
                isRightIcon: true,
                onTapRight: () {}),
        body: SafeArea(
                  child: GestureDetector(
                    onPanUpdate: (details){
                      if (details.delta.dy > 0) {
                        this.focusNode.unfocus();
                        }
                    },
                    child: Subscription("getMEssagedAdded",
                    subscribeToNewMessage,
                    variables: <String, String> {
                      "roomID": this.widget.room.id
                    },
                    
                    builder: ({dynamic error, bool loading, dynamic payload}) {
                      if(payload != null) {
                          this.widget.room.messages.insert(0, Message(createdAt:  payload["messageAdded"]["createdAt"], userId: payload["messageAdded"]["userId"], message:  payload["messageAdded"]["message"], isRead: false, isSent: true));
                          this.scrollToBottom();
                           
                      }
                
                

                return Stack(
                          children: [
                            Column(
                              children: [
                              Expanded(
                                child: ListView.builder(
                                  reverse: true,
                                  shrinkWrap: true,
                                  controller: _controller,
                                  itemCount: this.widget.room.messages.length,
                                  itemBuilder: (context, index){
                                    if(this.widget.room.messages[index].userId == databaseService.user.value.id) {
                                      return ListTile(
                                        title: Column(
                                          children: [
                                            ChatBubble(
                                                        elevation: 0,
                                                        shadowColor: Colors.white,
                                                        alignment: Alignment.topRight,
                                                        margin: EdgeInsets.only(top: 20),
                                                        clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                                                        child: Container(constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                                                      ), child: Text(this.widget.room.messages[index].message, style: GoogleFonts.montserrat(color: Colors.white),)),
                                                      ),

                                                      SizedBox(height: 5),

                                              Align(
                                                alignment: Alignment.centerRight,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(this.widget.room.messages[index].createdAt, style: GoogleFonts.montserrat(fontSize: 11),),
                                                    SizedBox(width:10),
                                                    IsReadWidget(isRead: this.widget.room.messages[index].isRead, isSent: this.widget.room.messages[index].isSent,)
                                                  ],
                                                ),
                                              )
                                          ],
                                        )
                                      );
                                    }else{
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            radius: 30,
                                            backgroundImage: NetworkImage(
                                                "https://t1.gstatic.com/images?q=tbn:ANd9GcRgexJ5aVLMRh8pTx4ktKg3JtDIFtxPR7DCPXkbqoUSA1vx6RBwb4TUGLKMW5fl"),
                                          ),
                                          title: Column(
                                            children: [
                                              ChatBubble(
                                                          elevation: 0,
                                                          alignment: Alignment.topLeft,
                                                          backGroundColor: Colors.grey[300],
                                                          shadowColor: Colors.white,
                                                          clipper: ChatBubbleClipper5(type: BubbleType.receiverBubble),
                                                          child: Container(constraints: BoxConstraints(
                                                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                                                        ), child: Text(this.widget.room.messages[index].message, style: GoogleFonts.montserrat(color: Colors.black))),
                                              ),

                                              SizedBox(height: 5),

                                              Align(alignment: Alignment.centerLeft, child: Text("date d'envoie", style: GoogleFonts.montserrat(fontSize: 11),))
                                            ],
                                          )
                                        ),
                                      );  
                                    }

                                    

                                  }
                                )
                              ),

                              MessageInput(textEditingController: this.textEditingController, message: messageToSend, focusNode: this.focusNode, animationDuration: Duration(milliseconds: 300), onSubmitted: (String message) {
                                print("the message has been submitted");
                              }, onAttachmentCiclked: (){
                                print("attachment was clicked");
                              }, onSendingClicked: (){
                                this.textEditingController.text = "";
                                this.sendMessage(this.messageToSend.value, this.widget.room.id, databaseService.user.value.id, client).then((value){
                                  this.messageToSend.add(null);
                                });
                              },)
                              ]
                            )
                        ],);
              }),
                  ),
        )
      );

    });
  }
}