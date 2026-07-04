import 'dart:io';

import 'package:kookers/Services/SupabaseService.dart';

/// Drop-in replacement for the legacy `StorageService` that uploads
/// to Supabase Storage instead of Firebase Storage.
///
/// Two buckets are required (create them in the Supabase dashboard):
///   - `publication_photos` — dish photos uploaded by sellers
///   - `profile_photos` — user avatar uploads
///
/// Both buckets should be public-read (RLS allows public read for
/// unauthenticated users; writes are restricted to the owner via the
/// `(storage.foldername(name))[1] = auth.uid()` policy pattern).
class SupabaseStorageService {
  SupabaseStorageService();

  static const _kPublicationBucket = 'publication_photos';
  static const _kProfileBucket = 'profile_photos';

  /// Uploads a picture file and returns its public URL.
  ///
  /// [uid] is the authenticated user's id; [pictureName] is the
  /// logical name (e.g. "photoUrl" or "pub1_photo1"); [uploadType]
  /// is "profilImage" or "publication" — used to pick the bucket.
  Future<String> uploadPictureFile(
    String uid,
    String pictureName,
    File file,
    String uploadType,
  ) async {
    final bucket = uploadType == 'profilImage'
        ? _kProfileBucket
        : _kPublicationBucket;
    final path = '$uid/$pictureName';
    await SupabaseService.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );
    return SupabaseService.storage.from(bucket).getPublicUrl(path);
  }

  /// Uploads a base64-encoded data URL. Returns the public URL.
  Future<String> uploadPicture(
    String uid,
    String pictureName,
    String dataUrl,
  ) async {
    // The legacy method accepted a data: URL. We decode the base64
    // portion and upload the raw bytes.
    final commaIdx = dataUrl.indexOf(',');
    final base64 = commaIdx >= 0 ? dataUrl.substring(commaIdx + 1) : dataUrl;
    final bytes = Uri.parse('data:;base64,$base64').data!.contentAsBytes();
    final path = '$uid/$pictureName';
    await SupabaseService.storage.from(_kProfileBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );
    return SupabaseService.storage.from(_kProfileBucket).getPublicUrl(path);
  }

  /// Returns the public URL for a previously-uploaded file.
  Future<String> getUrl(String uid, String pictureName) async {
    return SupabaseService.storage
        .from(_kProfileBucket)
        .getPublicUrl('$uid/$pictureName');
  }

  /// Static convenience: returns the public URL for a known path.
  static Future<String> downloadUrl(String path) async {
    // We assume profile bucket; if you need publication bucket, call
    // SupabaseService.storage.from('publication_photos').getPublicUrl(path)
    // directly.
    return SupabaseService.storage.from(_kProfileBucket).getPublicUrl(path);
  }
}
