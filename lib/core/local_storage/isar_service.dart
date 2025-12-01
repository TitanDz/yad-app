import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yad_app/features/auth/domain/models/user_model.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  static late Isar _isar;

  IsarService._internal();

  factory IsarService() {
    return _instance;
  }

  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // Note: Isar.open() requires at least one collection schema to be defined.
      // Since we're using in-memory caching for now, we skip Isar initialization.
      // TODO: Add Isar collection schemas when implementing persistent caching.
      // _isar = await Isar.open(
      //   [UserSchema], // Define schemas here when ready
      //   directory: dir.path,
      //   name: 'yad_app',
      // );
    } catch (e) {
      print('[IsarService] Failed to initialize Isar: $e. Using in-memory caching.');
    }
  }

  Isar? get isar => _isar;

  bool get isInitialized => _isar != null;

  Future<void> cacheUser(UserModel user) async {
    // TODO: Implement when Isar schema is defined
    // For now, storing in memory or shared preferences
  }

  Future<UserModel?> getCachedUser() async {
    // TODO: Implement when Isar schema is defined
    return null;
  }

  Future<void> clearCache() async {
    // TODO: Implement cache clearing
  }

  Future<void> close() async {
    if (_isar != null && _isar.isOpen) {
      await _isar.close();
    }
  }
}
