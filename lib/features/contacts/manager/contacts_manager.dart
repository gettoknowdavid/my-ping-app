import 'dart:async';

import 'package:ping/_ping.dart';
import 'package:ping/features/contacts/model/_model.dart';
import 'package:ping/features/contacts/services/_services.dart';

class ContactsManager implements Disposable {
  ContactsManager(this._service) {
    searchCommand = .createAsyncNoResult<String>((args) async {
      hasSearched.value = true;
      result.value = await _service.findByPhone(args);
    }, errorFilter: const GlobalIfNoLocalErrorFilter());

    searchCommand.errors.listen((error, _) {
      // Errors surface via command.errors —
      // ContactSearchPage registers a handler for these
    });

    _inputSubscription = _debouncedInput.listen((input, _) {
      if (input.trim().length >= 7) {
        searchCommand.run(input.trim());
      } else {
        result.value = null;
        hasSearched.value = false;
      }
    });
  }

  final ContactsService _service;

  final phoneInput = ValueNotifier<String>('');
  final result = ValueNotifier<ContactResult?>(null);
  final hasSearched = ValueNotifier<bool>(false);

  late final ValueListenable<String> _debouncedInput = phoneInput.debounce(
    const Duration(milliseconds: 500),
  );

  ListenableSubscription? _inputSubscription;

  late final Command<String, void> searchCommand;

  void clear() {
    phoneInput.value = '';
    result.value = null;
    hasSearched.value = false;
  }

  @override
  FutureOr<dynamic> onDispose() {
    _inputSubscription?.cancel();
    _inputSubscription = null;

    phoneInput.dispose();
    result.dispose();
    hasSearched.value = false;
    hasSearched.dispose();

    searchCommand.dispose();
  }
}
