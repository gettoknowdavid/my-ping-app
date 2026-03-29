import 'dart:developer';

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/contacts/model/_model.dart';

class ContactsService {
  const ContactsService(this._db);

  final DatabaseService _db;

  Future<ContactResult?> findByPhone(String phone) async {
    try {
      final response = await _db.client
          .rpc<dynamic>(
            'find_profile_by_phone',
            params: {'search_phone': phone},
          )
          .select()
          .limit(1);
      final data = response as List<dynamic>;
      if (data.isEmpty) return null;
      return ContactResult.fromJson(
        Map<String, Object?>.from(data.first as Map),
      );
    } on PostgrestException catch (error, stackTrace) {
      log('ContactsService', error: error, stackTrace: stackTrace);
      throw PingException(error.message);
    }
  }
}
