import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:provider/provider.dart';

class Receiver {
  String firstName;
  String lastName;
  String phonenumber;
  String photoUrl;
  String notificationToken;
  Receiver(
      {@required this.firstName, @required this.lastName, this.phonenumber, this.photoUrl, this.notificationToken});
}




class Room {
  String id;
  String updatedAt;
  String createdAt;
  int notificationCountUser_1;
  Receiver receiver;
  String lastMessage;
  List<Message> messages;
  Room(
      {@required this.id,
      @required this.updatedAt,
      this.createdAt,
      @required this.notificationCountUser_1,
      @required this.receiver,
      @required this.messages, this.lastMessage});


      static Room fromJson(Map<String, dynamic> map, String currentUser){
        List<Message> messages =  Message.fromJSON(map['messages'] as List<Object>).reversed.toList();
        String last = messages.length > 0 ? messages.first.message : "";
        int notificationCount = messages.length > 0 ? messages.where((element) => element.userId != currentUser).where((element) => element.isRead == false).length : 0;

        

        final room = Room(
        messages: messages,
        id: map['_id'] as String,
        notificationCountUser_1: notificationCount,
        updatedAt: map['updateAt'] as String,
        lastMessage: last,

        receiver: Receiver(
            firstName: map['receiver']["first_name"],
            lastName: map['receiver']["last_name"], photoUrl: map['receiver']["photoUrl"], notificationToken: map["receiver"]["fcmToken"])
        );

        return room;
      }



  static List<Room> fromJsonToList(List<Object> map, String currentUser) {
        List<Room> allpublications = [];
        map.forEach((element) {
          final x = Room.fromJson(element, currentUser);
          allpublications.add(x);
        });
        return allpublications;
      }
}

class Message {
  String userId;
  String message;
  String roomId;
  String createdAt;
  String messagePicture;
  bool isSent;
  bool isRead;
  String receiverPushToken;

  Message(
      {@required this.userId,
      @required this.message,
      @required this.createdAt,
      this.messagePicture, this.isRead, this.isSent, this.receiverPushToken, this.roomId});

  static List<Message> fromJSON(List<Object> map) {

    
    List<Message> messages = [];
    if(map != null){
      map.forEach((element) async {
        // await Jiffy.locale("fr");
        final dou = element as Map<String, dynamic>;
        final date = Jiffy(dou["createdAt"]);
        messages.add(Message(
          createdAt: date.format("do MMMM, HH:mm:ss"),
          userId: dou["userId"],
          message: dou["message"],
          isRead: dou["is_read"],
          isSent: dou["is_sent"],
          messagePicture: dou["message_picture"],
        ));
      });
    }
    return messages;
  }


  Map<String, dynamic> toJSON(){
    Map<String, dynamic> data = Map<String, dynamic>();
    data["userId"] = this.userId;
    data["message"] = this.message;
    data["message_picture"] = this.messagePicture;
    data["createdAt"] = this.createdAt;
    data["receiver_push_token"] = this.receiverPushToken;
    data["roomId"] = this.roomId;
    return data;
  }
}



class RoomItemShimmer extends StatelessWidget {
  const RoomItemShimmer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: ListTile(
            autofocus: false,
            title: Container(
              decoration: BoxDecoration(
                      color: Colors.grey[200],      
                    ),
              child: Text(
                "ONDONDA PRINCE",
                style: GoogleFonts.montserrat(fontSize: 15),
              ),
            ),
            subtitle: Container(
              decoration: BoxDecoration(
                                color: Colors.grey[200],      
                    ),
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
              radius: 30
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                                color: Colors.grey[200],      
                    ),
                  child: Text(
                    "il y'a 5 min",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            )),
                        child: Center(
                            child: Text(
                          "2",
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        )),
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }
}



class RoomItem extends StatelessWidget {
  final Room room;
  final int index;
  const RoomItem({Key key, @required this.room, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
        
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: ListTile(
            autofocus: false,
            title: Text(
              this.room.receiver.firstName + " " + this.room.receiver.lastName,
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            subtitle: Text(
              this.room.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
              radius: 30,
              backgroundImage: CachedNetworkImageProvider(this.room.receiver.photoUrl),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "il y'a 2 mins",
                  style: TextStyle(fontSize: 12),
                ),
                room.notificationCountUser_1 > 0
                    ? Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            )),
                        child: Center(
                            child: Text(
                          room.notificationCountUser_1.toString(),
                          style: TextStyle(fontSize: 11, color: Colors.white),
                        )),
                      )
                    : SizedBox()
              ],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => ChatPage(room: this.room, uid: databaseService.user.value.id)));
            },
          ),
        ),
      ],
    );
  }
}
