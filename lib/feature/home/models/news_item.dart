import 'package:freezed_annotation/freezed_annotation.dart';

part 'news_item.freezed.dart';
part 'news_item.g.dart';

/// ニュースアイテム
@freezed
class NewsItem with _$NewsItem {
  const factory NewsItem({
    required String title, // ニュースのタイトル
    required String summary, // ニュースの要約
    String? url, // ニュースのURL
    String? source, // 情報源
    DateTime? publishedAt, // 公開日時
    String? imageUrl, // サムネイル画像のURL
  }) = _NewsItem;

  factory NewsItem.fromJson(Map<String, dynamic> json) => _$NewsItemFromJson(json);
}
