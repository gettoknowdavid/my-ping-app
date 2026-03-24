import 'package:ping/_ping.dart';
import 'package:ping/_shared/models/db_model.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@Freezed(toJson: true)
abstract class Profile with _$Profile implements DbModel<Profile> {
  const factory Profile({
    required String id,
    required String phone,
    required int version,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    String? username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'deleted_at') DateTime? deletedAt,
    String? about,
  }) = _Profile;

  factory Profile.fromJson(Map<String, Object?> json) =>
      _$ProfileFromJson(json);

  static String get table_name => 'profiles';

  static String get c_id => 'id';

  static String get c_username => 'username';

  static String get c_displayName => 'display_name';

  static String get c_avatarUrl => 'avatar_url';

  static String get c_about => 'about';

  static String get c_phone => 'phone';

  static String get c_createdAt => 'created_at';

  static String get c_updatedAt => 'updated_at';

  static String get c_deletedAt => 'deleted_at';

  static String get c_version => 'version';

  static List<Profile> converter(List<Map<String, dynamic>> data) {
    return data.map(Profile.fromJson).toList();
  }

  static Map<String, dynamic> _generateMap({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? about,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
  }) {
    return {
      'id': ?id,
      'username': ?username,
      'display_name': ?displayName,
      'avatar_url': ?avatarUrl,
      'about': ?about,
      'phone': ?phone,
      if (createdAt != null) 'created_at': createdAt.toUtc().toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt.toUtc().toIso8601String(),
      'version': ?version,
    };
  }

  static Map<String, dynamic> insert({
    required String username,
    required String phone,
    String? id,
    String? displayName,
    String? avatarUrl,
    String? about,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
  }) {
    return _generateMap(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      about: about,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
    );
  }

  static Map<String, dynamic> update({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? about,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
  }) {
    return _generateMap(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      about: about,
      phone: phone,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
    );
  }
}
