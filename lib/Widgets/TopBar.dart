import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';


class TopBarTwoWithChat extends PreferredSize {
  final String title;
  final double? height;
  final bool? isRightIcon;
  final IconData? rightIcon;
  final Function? onTapRight;
  const TopBarTwoWithChat({Key? key, required this.title, this.isRightIcon, this.rightIcon, this.onTapRight, this.height}) : super(key: key, child: const SizedBox(), preferredSize: const Size.fromHeight(56));

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          autofocus: false,
          leading: InkWell(onTap: () => Navigator.pop(context), child: Icon(CupertinoIcons.chevron_back)),
          title: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          trailing: Visibility(visible: this.isRightIcon ?? false, child: InkWell(onTap: this.onTapRight as GestureTapCallback?, child: Icon(this.rightIcon ?? CupertinoIcons.ellipsis)),
        ),
      )
      ),
    );
  }
}

class TopBarWitRightTitle extends PreferredSize {
  final String title;
  final double? height;
  final Function? onTapRight;
  final String? rightText;
  const TopBarWitRightTitle({Key? key, required this.title,  this.onTapRight, this.height, this.rightText}) : super(key: key, child: const SizedBox(), preferredSize: const Size.fromHeight(56));

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          autofocus: false,
          leading: InkWell(onTap: (){
            Get.back();
          }, child: Icon(CupertinoIcons.multiply, color: Colors.black,),),
          title: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          trailing: InkWell(onTap: this.onTapRight as GestureTapCallback?, child: Text(this.rightText ?? "", style: GoogleFonts.montserrat(fontSize: 17),)),
      )
      ),
    );
  }
}


class TopBarBackCross extends PreferredSize {
  final String title;
  final double? height;
  const TopBarBackCross({Key? key, required this.title,  this.height}) : super(key: key, child: const SizedBox(), preferredSize: const Size.fromHeight(56));

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          autofocus: false,
          leading: InkWell(onTap: (){
            Get.back();
          }, child: Icon(CupertinoIcons.multiply, color: Colors.black,),),
          title: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
      )
      ),
    );
  }
}

class TopBarWitBackNav extends PreferredSize {
  final String title;
  final double? height;
  final bool? isRightIcon;
  final IconData? rightIcon;
  final Function? onTapRight;
  const TopBarWitBackNav({Key? key, required this.title, this.isRightIcon, this.rightIcon, this.onTapRight, this.height}) : super(key: key, child: const SizedBox(), preferredSize: const Size.fromHeight(56));

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          autofocus: false,
          leading: InkWell(onTap: () => Navigator.pop(context), child: Icon(CupertinoIcons.chevron_back)),
          title: Text(this.title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          trailing: Visibility(visible: this.isRightIcon ?? false, child: InkWell(onTap: this.onTapRight as GestureTapCallback?, child: Icon(this.rightIcon ?? CupertinoIcons.ellipsis)),
        ),
      )
      ),
    );
  }
}


class TopBarChat extends PreferredSize {
  final String displayname;
  final bool? isRightIcon;
  final IconData? rightIcon;
  final Function? onTapRight;
  final String? imageUrl;
  final double? height;
  const TopBarChat({Key? key, required this.displayname, this.isRightIcon, this.rightIcon, this.onTapRight, this.height, this.imageUrl}) : super(key: key, child: const SizedBox(), preferredSize: const Size.fromHeight(56));

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Container(
        height: preferredSize.height,
        child: ListTile(
          autofocus: false,
          leading: InkWell(onTap: () => Navigator.pop(context), child: Icon(CupertinoIcons.chevron_back)),
          title: Row(children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.white,
                radius: 20,
                backgroundImage: this.imageUrl != null ? CachedNetworkImageProvider(this.imageUrl!) : null,
            ),
            SizedBox(width: 10),
            Text(this.displayname, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black))
          ],),
          trailing: Visibility(visible: this.isRightIcon ?? false, child: InkWell(onTap: this.onTapRight as GestureTapCallback?, child: Icon(this.rightIcon ?? CupertinoIcons.ellipsis)),
        ),
      )
      ),
    );
  }
}