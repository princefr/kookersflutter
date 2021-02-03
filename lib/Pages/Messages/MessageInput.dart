import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';


class MessageInput extends StatefulWidget {
  const MessageInput({Key key, this.keyboardType = TextInputType.multiline, this.disableAttachments = false, this.animationDuration, this.attachmentIconColor, this.maxHeight = 130, this.message, this.focusNode, this.onSubmitted, this.autofocus = false, this.onAttachmentCiclked, this.onSendingClicked, this.textEditingController, this.image}) : super(key: key);

  final BehaviorSubject<String> message;
  final BehaviorSubject<File> image;

  final double maxHeight;

  /// The keyboard type assigned to the TextField
  final TextInputType keyboardType;


   /// If true the attachments button will not be displayed
  final bool disableAttachments;


  /// The duration of the send button animation
  final Duration animationDuration;

  /// Color used for attachment icon.
  final Color attachmentIconColor;

  /// focus node
  final FocusNode focusNode;


/// If set true TextField will be active by default. Default is false.
  final bool autofocus;


  final TextEditingController textEditingController;


  final Function(String) onSubmitted;

  final void Function() onAttachmentCiclked;
  final void Function() onSendingClicked;


  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {


@override
  void dispose() {
    this.widget.focusNode.dispose();
    this.widget.textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        AnimatedContainer(
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 600),
          child: StreamBuilder<Object>(
            stream: this.widget.image.stream,
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                          decoration: BoxDecoration(color: Colors.grey[200],    
                          borderRadius: BorderRadius.all(Radius.circular(10.0)) ,
                          image: DecorationImage(image: Image.file(snapshot.data).image, fit: BoxFit.cover, alignment: Alignment.center)
                            ),
                        height: 150,
                      ),
                    ),

                               Positioned(
                top: 10,
                right: 30,
                child: InkWell(
                  onTap: () {
                    this.widget.image.sink.add(null);
                  },
                  child: Container(
                      padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 7),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 255, 43, 84),
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Icon(
                        CupertinoIcons.multiply,
                        color: Colors.white,
                        size: 20.0,
                      )),
                ),
              )
                  ],
                );
              }
              return SizedBox();
            }
          ),
        ),

        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
          leading: InkWell(onTap: this.widget.onAttachmentCiclked, child: Icon(CupertinoIcons.plus, color: Colors.black, size: 30)),
          trailing: StreamBuilder<String>(
            stream: this.widget.message.stream,
            builder: (context, snapshot) {
              return InkWell(onTap: (snapshot.data != null && snapshot.data.isNotEmpty) ? this.widget.onSendingClicked : null, child: Icon(CupertinoIcons.arrow_up_circle_fill, color: (snapshot.data != null && snapshot.data.isNotEmpty) ? Colors.black : Colors.grey, size: 30));
            }
          ),
          title: LimitedBox(
            maxHeight: widget.maxHeight,
            child: StreamBuilder<String>(
              stream: this.widget.message.stream,
              builder: (context, AsyncSnapshot<String> snapshot) {
                return TextField(
                  key: Key('messageInputText'),
                  minLines: null,
                  maxLines: null,
                  controller: this.widget.textEditingController,
                  onSubmitted: (snapshot.data != null && snapshot.data.isNotEmpty) ? this.widget.onSubmitted : null,
                  focusNode: this.widget.focusNode,
                  keyboardType: widget.keyboardType,
                  onChanged: this.widget.message.add,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  hintText: 'Type your message...', contentPadding: EdgeInsets.symmetric(horizontal: 10), hintStyle: TextStyle(color: Colors.grey))
                );
              }
            ),
          )
        ),
      ],
    );
  }
}