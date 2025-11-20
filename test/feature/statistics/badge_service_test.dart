import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tyarekyara/feature/statistics/models/badge.dart';
import 'package:tyarekyara/feature/statistics/models/earned_badge.dart';
import 'package:tyarekyara/feature/statistics/repositories/badge_repository.dart';
import 'package:tyarekyara/feature/statistics/services/badge_service.dart';

@GenerateMocks([BadgeRepository])
import 'badge_service_test.mocks.dart';

void main() {
  late BadgeService badgeService;
  late MockBadgeRepository mockBadgeRepository;

  setUp(() {
    mockBadgeRepository = MockBadgeRepository();
    badgeService = BadgeService(mockBadgeRepository);
  });

  final testBadge = Badge(
    id: 'b_login_3',
    name: 'Test Badge',
    description: 'Test Description',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    criteria: {'days': '3', 'field': 'login', 'type': 'streak'},
  );

  test('initialize loads catalog', () async {
    when(
      mockBadgeRepository.fetchCatalog(),
    ).thenAnswer((_) async => [testBadge]);

    await badgeService.initialize();

    verify(mockBadgeRepository.fetchCatalog()).called(1);
  });

  test('checkCondition awards badge when criteria is met', () async {
    when(
      mockBadgeRepository.fetchCatalog(),
    ).thenAnswer((_) async => [testBadge]);
    when(
      mockBadgeRepository.fetchEarnedBadges(any),
    ).thenAnswer((_) async => []);
    when(
      mockBadgeRepository.saveEarnedBadge(any, any),
    ).thenAnswer((_) async => Future.value());

    await badgeService.checkCondition('user1', 'login', 3);

    verify(mockBadgeRepository.saveEarnedBadge('user1', any)).called(1);
  });

  test(
    'checkCondition does not award badge when criteria is NOT met',
    () async {
      when(
        mockBadgeRepository.fetchCatalog(),
      ).thenAnswer((_) async => [testBadge]);
      when(
        mockBadgeRepository.fetchEarnedBadges(any),
      ).thenAnswer((_) async => []);

      await badgeService.checkCondition('user1', 'login', 2);

      verifyNever(mockBadgeRepository.saveEarnedBadge(any, any));
    },
  );

  test('checkCondition does not award badge if already earned', () async {
    when(
      mockBadgeRepository.fetchCatalog(),
    ).thenAnswer((_) async => [testBadge]);
    when(mockBadgeRepository.fetchEarnedBadges(any)).thenAnswer(
      (_) async => [
        Badge(
          id: 'b_login_3',
          name: 'Test Badge',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          earnedAt: DateTime.now(),
        ),
      ],
    );

    await badgeService.checkCondition('user1', 'login', 3);

    verifyNever(mockBadgeRepository.saveEarnedBadge(any, any));
  });
}
