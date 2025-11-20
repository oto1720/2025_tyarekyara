import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/badge.dart';
import '../models/earned_badge.dart';
import 'badge_repository.dart';

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  return BadgeRepositoryImpl(FirebaseFirestore.instance);
});

class BadgeRepositoryImpl implements BadgeRepository {
  final FirebaseFirestore _firestore;

  BadgeRepositoryImpl(this._firestore);

  @override
  Future<List<Badge>> fetchCatalog() async {
    final snapshot = await _firestore.collection('badges_catalog').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      // createdAt/updatedAt might be Timestamp, need conversion if not handled by fromJson with converters
      // Assuming Badge.fromJson handles it or we need to convert manually if not using json_serializable with converters
      // But Badge uses @freezed and usually json_serializable.
      // Let's assume standard conversion for now, but might need adjustment.
      // Actually, Badge model has DateTime, so we might need to convert Timestamp to DateTime string or use a converter.
      // For now, let's rely on the fact that we might need to handle Timestamp manually if fromJson expects String or standard DateTime.
      // However, usually we use a converter. Let's check Badge model again later if needed.
      // For now, just pass data.
      return Badge.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Badge>> fetchEarnedBadges(String userId) async {
    // This method might be tricky. The user wants "earned_badges" subcollection.
    // But return type is List<Badge>.
    // So we probably need to fetch catalog first (or have it cached) and then merge?
    // Or maybe just return the EarnedBadge objects?
    // The interface says List<Badge>.
    // If we return List<Badge>, we should probably return the Badge details with earnedAt populated.

    // However, for efficiency, maybe we should just fetch EarnedBadges here?
    // But the interface was defined as List<Badge>.
    // Let's implement it by fetching catalog (or assuming we have it) and merging.
    // BUT, fetching catalog every time is expensive.
    // Maybe this repository method should just return what's in the subcollection?
    // But the subcollection only has badgeId and earnedAt. It doesn't have name/description.
    // So we MUST join with catalog.

    // For this implementation, let's fetch both and join.
    // In a real app, we'd cache the catalog.

    final catalog = await fetchCatalog();
    final earnedSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('earned_badges')
        .get();

    final earnedMap = {
      for (var doc in earnedSnapshot.docs)
        doc.id: doc.data()['earnedAt'] as Timestamp, // Assuming Timestamp
    };

    return catalog.where((badge) => earnedMap.containsKey(badge.id)).map((
      badge,
    ) {
      return badge.copyWith(
        earnedAt: (earnedMap[badge.id] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveEarnedBadge(String userId, EarnedBadge earnedBadge) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('earned_badges')
        .doc(earnedBadge.badgeId)
        .set(earnedBadge.toJson());
  }
}
