

import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  Future<PermissionStatus> requestMicrophonePermission() => Permission.microphone.request();
  Future<PermissionStatus> requestNotificationPermission() => Permission.notification.request();
  Future<PermissionStatus> requestCameraPermission() => Permission.camera.request();
  Future<PermissionStatus> requestMediaPermission() => Permission.mediaLibrary.request();
}