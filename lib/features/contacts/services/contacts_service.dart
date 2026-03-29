// coverage:ignore-file
// ignore_for_file: inference_failure_on_function_invocation

import 'package:ping/_ping.dart';
import 'package:ping/_shared/_shared.dart';
import 'package:ping/features/contacts/model/_model.dart';

class ContactsService {
  const ContactsService(this._db);

  final DatabaseService _db;

  Future<ContactResult?> findContactByPhone(String phone) async {
    try {
      final response = await _db.client
          .rpc('find_profile_by_phone', params: {'search_phone': phone})
          .maybeSingle();
      if (response == null) return null;
      return ContactResult.fromJson(response);
    } on PostgrestException catch (e) {
      throw PingException(e.message);
    }
  }
}
