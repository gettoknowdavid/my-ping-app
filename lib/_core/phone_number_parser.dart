import 'package:dlibphonenumber/dlibphonenumber.dart';

String parsePhoneNumber(String number) {
  final util = PhoneNumberUtil.instance;
  final phoneNumber = util.parse('+$number', '');
  return util.format(phoneNumber, .international);
}
