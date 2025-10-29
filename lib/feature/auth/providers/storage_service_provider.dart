import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// StorageServiceのProvider
/// シングルトンとしてStorageServiceを提供
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
