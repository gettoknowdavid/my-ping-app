import 'package:objectbox/objectbox.dart';

@Entity()
class LocalProfile {
  LocalProfile({
    required this.remoteId,
    required this.phone,
    required this.syncedAt,
    this.boxId = 0,
    this.displayName,
    this.avatarUrl,
    this.about,
  });

  @Id()
  int boxId;

  @Unique()
  String remoteId;

  String? displayName;

  String? avatarUrl;

  String? about;

  String phone;

  DateTime syncedAt;
}
