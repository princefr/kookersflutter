import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class TopBarWitBackNav extends PreferredSize {
  final String title;
  final double height;
  final bool isRightIcon;
  final IconData rightIcon;
  final Function onTapRight;
  const TopBarWitBackNav({Key key, @required this.title, this.isRightIcon, this.rightIcon, this.onTapRight, this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          leading: InkWell(onTap: () => Navigator.pop(context), child: Icon(CupertinoIcons.chevron_back)),
          title: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          trailing: Visibility(visible: this.isRightIcon, child: InkWell(onTap: this.onTapRight, child: Icon(this.rightIcon)),
        ),
      )
      ),
    );
  }
}


class TopBarChat extends PreferredSize {
  final String displayname;
  final bool isRightIcon;
  final IconData rightIcon;
  final Function onTapRight;
  final double height;
  const TopBarChat({Key key, @required this.displayname, this.isRightIcon, this.rightIcon, this.onTapRight, this.height});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          leading: InkWell(onTap: () => Navigator.pop(context), child: Icon(CupertinoIcons.chevron_back)),
          title: Row(children: [
            CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage("https://t1.gstatic.com/images?q=tbn:ANd9GcRgexJ5aVLMRh8pTx4ktKg3JtDIFtxPR7DCPXkbqoUSA1vx6RBwb4TUGLKMW5fl"),
            ),
            SizedBox(width: 10),
            Text(this.displayname, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black))
          ],),
          trailing: Visibility(visible: this.isRightIcon, child: InkWell(onTap: this.onTapRight, child: Icon(this.rightIcon)),
        ),
      )
      ),
    );
  }
}