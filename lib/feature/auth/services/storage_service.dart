import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Firebase Storageを使用した画像アップロードサービス
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// ユーザーのプロフィール画像をアップロード
  ///
  /// [userId] ユーザーID
  /// [imageFile] アップロードする画像ファイル
  ///
  /// Returns: アップロードされた画像のダウンロードURL
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // ファイル拡張子を取得
      final ext = path.extension(imageFile.path);
      // ストレージパスを設定（profile_images/userId.拡張子）
      final storageRef = _storage.ref().child('profile_images/$userId$ext');

      // メタデータを設定
      final metadata = SettableMetadata(
        contentType: 'image/${ext.replaceAll('.', '')}',
        customMetadata: {'userId': userId},
      );

      // 画像をアップロード
      final uploadTask = await storageRef.putFile(imageFile, metadata);

      // ダウンロードURLを取得
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw _handleStorageError(e);
    } catch (e) {
      throw '画像のアップロードに失敗しました: $e';
    }
  }

  /// ユーザーのプロフィール画像を削除
  ///
  /// [imageUrl] 削除する画像のURL
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // URLからストレージ参照を取得
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      // ファイルが存在しない場合はエラーを無視
      if (e.code != 'object-not-found') {
        throw _handleStorageError(e);
      }
    } catch (e) {
      throw '画像の削除に失敗しました: $e';
    }
  }

  /// Firebase Storageのエラーを処理
  String _handleStorageError(FirebaseException e) {
    switch (e.code) {
      case 'unauthorized':
        return 'アップロードする権限がありません';
      case 'canceled':
        return 'アップロードがキャンセルされました';
      case 'unknown':
        return '不明なエラーが発生しました';
      case 'object-not-found':
        return 'ファイルが見つかりません';
      case 'bucket-not-found':
        return 'ストレージバケットが見つかりません';
      case 'quota-exceeded':
        return 'ストレージの容量制限を超えています';
      case 'unauthenticated':
        return '認証が必要です';
      default:
        return 'エラーが発生しました: ${e.message}';
    }
  }
}
