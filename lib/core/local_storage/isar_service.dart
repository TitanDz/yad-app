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
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [],
      directory: dir.path,
      name: 'yad_app',
    );
  }

  Isar get isar => _isar;

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
    await _isar.close();
  }
}
