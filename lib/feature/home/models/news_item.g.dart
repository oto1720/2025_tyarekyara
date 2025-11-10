// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsItemImpl _$$NewsItemImplFromJson(Map<String, dynamic> json) =>
    _$NewsItemImpl(
      title: json['title'] as String,
      summary: json['summary'] as String,
      url: json['url'] as String?,
      source: json['source'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$NewsItemImplToJson(_$NewsItemImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'summary': instance.summary,
      'url': instance.url,
      'source': instance.source,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'imageUrl': instance.imageUrl,
    };
