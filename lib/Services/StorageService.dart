import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class StorageService {
  final firebase_storage.FirebaseStorage storage;

  StorageService({required this.storage});

  Future<String> uploadPicture(String uid, String pictureName, String data) async {
    firebase_storage.Reference ref = storage
        .ref()
        .child(uid)
        .child(pictureName);
        await ref.putString(data, format: firebase_storage.PutStringFormat.dataUrl);
        final url = await ref.getDownloadURL();
        return  url;
  }


  Future<String> getUrl(String uid, String pictureName){
        firebase_storage.Reference ref = storage
        .ref()
        .child(uid)
        .child(pictureName);
        return ref.getDownloadURL();
  }

  static Future<String> downloadUrl(String path) async {
    String url = await firebase_storage.FirebaseStorage.instance.ref(path).getDownloadURL();
    return url;
  }
 
  Future<String>  uploadPictureFile(String uid, String pictureName, File file, String uploadType) async {
        firebase_storage.SettableMetadata metadata = firebase_storage.SettableMetadata(
        cacheControl: 'max-age=60',
        customMetadata: <String, String>{
          'type': uploadType,
        },
      );
        firebase_storage.Reference ref = storage
        .ref()
        .child(uid)
        .child(pictureName);
        await ref.putFile(file, metadata);
        return await ref.getDownloadURL();
  }
}