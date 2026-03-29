import 'package:ping/_ping.dart';

part 'contact_result.freezed.dart';

@Freezed(toJson: false)
abstract class ContactResult with _$ContactResult {
  const factory ContactResult({
    required String id,
    required String phone,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? about,
  }) = _ContactResult;

  const ContactResult._();

  // Convenience — display label falls back gracefully
  String get label => displayName ?? phone;
}
