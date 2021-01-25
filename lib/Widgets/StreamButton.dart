import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Widgets/KookersButton.dart';
import 'package:lottie/lottie.dart';



class StreamButtonController  {
  ValueNotifier<StreamButtonState> status;

  StreamButtonController() {
    status = ValueNotifier(StreamButtonState.Normal);
  }


  
  void initState() { 
    this.status.value = StreamButtonState.Normal;
    
  }

  void dispose(){
    this.status.dispose();
  }

  
  void isLoading(){
    this.status.value = StreamButtonState.Loading;
  }


  Future<void> isSuccess() async {
    this.status.value = StreamButtonState.Success;
    return Future.delayed(Duration(seconds: 3)).then((value)  {
      return this.status.value = StreamButtonState.Normal;
    });
  }


  Future<void> isError() async {
    this.status.value = StreamButtonState.Error;
    Future.delayed(Duration(seconds: 3)).then((value)  {
      this.status.value = StreamButtonState.Normal;
    });
  }


  
}


enum StreamButtonState {
  Normal, Loading, Success, Error
}

class StreamButton extends StatefulWidget {
  final StreamButtonController controller;
  final Function onClick;
  final String buttonText;
  final String successText;
  final String errorText;
  final String loadingText;
  final Color buttonColor;
  
  StreamButton({Key key, @required this.buttonText, @required this.controller,@required this.onClick, @required this.successText,@required this.errorText, @required this.loadingText, @required this.buttonColor}) : super(key: key);

  @override
  _StreamButtonState createState() => _StreamButtonState();
}

class _StreamButtonState extends State<StreamButton> {
  @override
  void initState() { 
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  
  }


  @override
  void didUpdateWidget(covariant StreamButton oldWidget) {
    if(this.widget.controller != oldWidget.controller){
      this.widget.controller.status.value = oldWidget.controller.status.value;
    }
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: this.widget.controller.status,
      builder: (BuildContext context, StreamButtonState state, Widget child){
        return AnimatedContainer(
          curve: Curves.easeIn,
          duration: Duration(milliseconds: 600),
          child: Builder(builder: (ctx) {
                switch (state) {
                  case StreamButtonState.Normal:
                    return FlatButton(onPressed: this.widget.onClick, child: KookersButton(text: this.widget.buttonText, color: this.widget.buttonColor, textcolor: Colors.white));
                    break;
                  case StreamButtonState.Loading:
                      return Center(
                        child: ListTile(
                          leading: SizedBox(),
                          trailing: CupertinoActivityIndicator(radius: 15),
                          title: Text(this.widget.loadingText, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      );
                    break;
                  case StreamButtonState.Error:
                      return ListTile(
                        leading: SizedBox(),
                        trailing: Container(height:55, width: 55,child: Lottie.asset('assets/lottie/lf30_editor_g0zf4bru.json', width: 45, height: 45, fit: BoxFit.fill, repeat: false)),
                        title: Text(this.widget.errorText, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                      );
                    break;
                  case StreamButtonState.Success:
                      return ListTile(
                        leading: SizedBox(),
                        trailing: Container(height:55, width: 55,child: Lottie.asset('assets/lottie/lf30_editor_m8symrlg.json', width: 45, height: 45, fit: BoxFit.fill, repeat: false)),
                        title: Text(this.widget.successText, style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold)),
                      );
                    break;
                  default:
                    return FlatButton(onPressed: this.widget.onClick, child: KookersButton(text: this.widget.buttonText, color: Colors.black, textcolor: Colors.white));
                }
              })
        );
    });
  }
}