import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('=== プロフィール画像アップロード開始 ===');
      debugPrint('ユーザーID: $userId');
      debugPrint('画像パス: ${imageFile.path}');

      // ファイルの存在確認
      final fileExists = await imageFile.exists();
      debugPrint('ファイル存在確認: $fileExists');

      if (!fileExists) {
        throw 'ファイルが見つかりません: ${imageFile.path}';
      }

      // ファイル拡張子を取得
      final ext = path.extension(imageFile.path);
      debugPrint('ファイル拡張子: $ext');

      if (ext.isEmpty) {
        throw 'ファイル拡張子が取得できません';
      }

      // ストレージパスを設定（profile_images/userId.拡張子）
      final storageRef = _storage.ref().child('profile_images/$userId$ext');
      debugPrint('ストレージパス: profile_images/$userId$ext');

      // メタデータを設定
      final metadata = SettableMetadata(
        contentType: 'image/${ext.replaceAll('.', '')}',
        customMetadata: {'userId': userId},
      );

      // 画像をアップロード
      debugPrint('アップロード開始...');
      final uploadTask = storageRef.putFile(imageFile, metadata);

      // アップロードの完了を待つ
      final snapshot = await uploadTask.whenComplete(() {});
      debugPrint('アップロード完了: ${snapshot.state}');

      // ダウンロードURLを取得
      debugPrint('ダウンロードURL取得中...');
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('ダウンロードURL取得 (raw): $downloadUrl');

      // URLをクリーンアップ（改行や余分な空白を除去）
      final cleanUrl = downloadUrl.trim().replaceAll(RegExp(r'\s+'), '');
      debugPrint('ダウンロードURL取得 (cleaned): $cleanUrl');
      debugPrint('=== プロフィール画像アップロード成功 ===');

      return cleanUrl;
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException: ${e.code} - ${e.message}');
      throw _handleStorageError(e);
    } catch (e, stackTrace) {
      debugPrint('アップロードエラー: $e');
      debugPrint('スタックトレース: $stackTrace');
      throw 'プロフィール画像のアップロードに失敗しました: $e';
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
