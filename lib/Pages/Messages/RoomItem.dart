import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Pages/Messages/ChatPage.dart';

class Receiver {
  String firstName;
  String lastName;
  String phonenumber;
  String photoUrl;
  Receiver(
      {@required this.firstName, @required this.lastName, this.phonenumber, this.photoUrl});
}




class Room {
  String id;
  String updatedAt;
  String createdAt;
  int notificationCountUser_1;
  Receiver receiver;
  List<Message> messages;
  Room(
      {@required this.id,
      @required this.updatedAt,
      this.createdAt,
      @required this.notificationCountUser_1,
      @required this.receiver,
      @required this.messages});

  static Room fromJson(Map<String, dynamic> map) => Room(
        messages: Message.fromJSON(map['messages'] as List<Object>),
        id: map['_id'] as String,
        notificationCountUser_1: map['notificationCountUser_1'] as int,
        updatedAt: map['updateAt'] as String,
        receiver: Receiver(
            firstName: map['receiver']["first_name"],
            lastName: map['receiver']["last_name"], photoUrl: map['receiver']["photoUrl"]),
      );

      static List<Room> fromJsonToList(List<Object> map) {
            List<Room> allpublications = [];
            map.forEach((element) {
              final x = Room.fromJson(element);
              allpublications.add(x);
            });
            return allpublications;
          }
}

class Message {
  String userId;
  String message;
  String createdAt;
  String messagePicture;
  Message(
      {@required this.userId,
      @required this.message,
      @required this.createdAt,
      this.messagePicture});

  static List<Message> fromJSON(List<Object> map) {
    List<Message> messages = [];
    if(map != null){
      map.forEach((element) {
        final dou = element as Map<String, dynamic>;
        messages.add(Message(
          createdAt: dou["createdAt"],
          userId: dou["userId"],
          message: dou["message"],
          messagePicture: dou["messagePicture"],
        ));
      });
    }

    return messages;
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
  const RoomItem({Key key, @required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: ListTile(
            title: Text(
              this.room.receiver.firstName + " " + this.room.receiver.lastName,
              style: GoogleFonts.montserrat(fontSize: 16),
            ),
            subtitle: Text(
              "ondonda",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12),
            ),
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                  this.room.receiver.photoUrl),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  this.room.updatedAt,
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
                      builder: (context) => ChatPage(room: this.room)));
            },
          ),
        ),
      ],
    );
  }
}
