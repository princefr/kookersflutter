import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_5.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:kookers/Pages/Messages/RoomItem.dart';
import 'package:kookers/Widgets/TopBar.dart';


class MessageBuble extends StatelessWidget {
  const MessageBuble({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    
    );
  }
}



class ChatPage extends StatefulWidget {
  final Room room;
  ChatPage({Key key,@required this.room}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {



Future<QueryResult> sendMessage(String message, String roomId, String userId, GraphQLClient client) async{
  final MutationOptions _options  = MutationOptions(
    documentNode: gql(r"""
      mutation SendMEssage($message: String!, $roomId: ID!, $userId: String!){
            sendMessage(message: {message: $message, roomId: $roomId, userId: $userId})
        }
    """),
    variables:  <String, String> {
      "message": message,
      "roomId": roomId,
      "userId": userId,
      "createdAt": DateTime.now().toIso8601String()
    }
  );

  return await client.mutate(_options);
}




final TextEditingController textEditingController = TextEditingController();
final FocusNode focusNode = FocusNode();
final _controller = ScrollController();


@override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
  }

    void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear

    }
  }


  void scrollToBottom() {
      // After 1 second, it takes you to the bottom of the ListView
      _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
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
    return GraphQLConsumer(builder: (GraphQLClient client) {
      return Scaffold(
        appBar: TopBarChat(displayname: this.widget.room.receiver.firstName + " " + this.widget.room.receiver.lastName, rightIcon: CupertinoIcons.exclamationmark_circle_fill,
        height: 54,
                            isRightIcon: true,
                            onTapRight: () {}),
        body: Subscription("getMEssagedAdded",
             subscribeToNewMessage,
             variables: <String, String> {
               "roomID": this.widget.room.id
             },
            builder: ({dynamic error, bool loading, dynamic payload}) {
              print(payload);
              print(error);

              return Stack(
                      children: [
                        Column(
                          children: [
                          Flexible(
                            child: Container(
                              child : ListView.builder(
                                controller: _controller,
                                itemCount: this.widget.room.messages.length,
                                itemBuilder: (context, index){

                                  if(this.widget.room.messages[index].userId == "5f560ef2ec675e097f84c990") {
                                    return ListTile(
                                      title: ChatBubble(
                                                  alignment: Alignment.topRight,
                                                  margin: EdgeInsets.only(top: 20),
                                                  clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                                                  child: Container(constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                                ), child: Text(this.widget.room.messages[index].message, style: GoogleFonts.montserrat(color: Colors.white),)),
                                                )
                                    );
                                  }else{
                                    return ListTile(
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            "https://t1.gstatic.com/images?q=tbn:ANd9GcRgexJ5aVLMRh8pTx4ktKg3JtDIFtxPR7DCPXkbqoUSA1vx6RBwb4TUGLKMW5fl"),
                                      ),
                                      title: ChatBubble(
                                                  alignment: Alignment.topLeft,
                                                  clipper: ChatBubbleClipper5(type: BubbleType.receiverBubble),
                                                  child: Container(constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                                ), child: Text(this.widget.room.messages[index].message, style: GoogleFonts.montserrat(color: Colors.black))),
                                                )
                                    );  
                                  }

                                  

                                }
                              )
                            )
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: ListTile(
                              leading: InkWell(onTap: (){}, child: Icon(CupertinoIcons.plus, color: Colors.black, size: 30)),
                              title: TextField(
                                minLines: 1,
                                maxLines: 5,
                                controller: textEditingController, decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                hintText: 'Type your message...', contentPadding: EdgeInsets.all(20.0), hintStyle: TextStyle(color: Colors.grey)), focusNode: focusNode,),
                              trailing: InkWell(onTap: (){
                                this.sendMessage(textEditingController.text, this.widget.room.id, "5f560ef2ec675e097f84c990", client).then((value){
                                  setState(() {
                                    textEditingController.clear();
                                    this.scrollToBottom();
                                  });
                                });
                              }, child: Icon(CupertinoIcons.arrow_up_circle_fill, color: Colors.black, size: 30)),
                            ),
                          )
                          ]
                        )
                    ],);
            })
      );

    });
  }
}