import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';


class MessageInput extends StatefulWidget {
  const MessageInput({Key key, this.keyboardType = TextInputType.multiline, this.disableAttachments = false, this.animationDuration, this.attachmentIconColor, this.maxHeight = 130, this.message, this.focusNode, this.onSubmitted, this.autofocus = false, this.onAttachmentCiclked, this.onSendingClicked, this.textEditingController}) : super(key: key);

  final BehaviorSubject<String> message;

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
  Widget build(BuildContext context) {
    return ListTile(
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
              minLines: 1,
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
                              hintText: 'Type your message...', contentPadding: EdgeInsets.all(20.0), hintStyle: TextStyle(color: Colors.grey))
            );
          }
        ),
      )
    );
  }
}