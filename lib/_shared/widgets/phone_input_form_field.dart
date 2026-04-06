import 'package:flutter/material.dart';
import 'package:intl_mobile_field/countries.dart';
import 'package:intl_mobile_field/country_picker_dialog.dart';
import 'package:intl_mobile_field/flags_drop_down.dart';
import 'package:intl_mobile_field/intl_mobile_field.dart';
import 'package:intl_mobile_field/mobile_number.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PhoneInputFormField extends StatefulWidget {
  const PhoneInputFormField({
    super.key,
    this.id,
    this.label,
    this.placeholder,
    this.onChanged,
    this.validator,
    this.initialCountryCode = 'NG',
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.labelStyle,
    this.initialValue,
  });

  final String? id;
  final Widget? label;
  final Widget? placeholder;
  final ValueChanged<MobileNumber>? onChanged;
  final String? Function(MobileNumber?)? validator;
  final String initialCountryCode;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final TextStyle? labelStyle;
  final MobileNumber? initialValue;

  @override
  State<PhoneInputFormField> createState() => _PhoneInputFormFieldState();
}

class _PhoneInputFormFieldState extends State<PhoneInputFormField> {
  late Country _selectedCountry;

  String get _selectedCountryDialCode => '+${_selectedCountry.fullCountryCode}';

  MobileNumber _buildMobileNumber(String? number) {
    return MobileNumber(
      countryISOCode: _selectedCountry.code,
      countryCode: _selectedCountryDialCode,
      number: number ?? '',
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedCountry = countries.firstWhere(
      (e) => e.code == widget.initialCountryCode,
    );

    if (widget.initialValue != null && widget.onChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged?.call(widget.initialValue!);
      });
    }
  }

  void _onChanged(String value) {
    final mobileNumber = _buildMobileNumber(value);
    widget.onChanged?.call(mobileNumber);
  }

  String? _validateSync(String? input) {
    final mobileNumber = _buildMobileNumber(input);
    final value = mobileNumber.number;

    final result = widget.validator?.call(mobileNumber);
    if (result is String) return result;

    if (value.isEmpty) return null;

    if (!isNumeric(value)) return 'Invalid phone number';

    final isValidLength =
        value.length >= _selectedCountry.minLength &&
        value.length <= _selectedCountry.maxLength;

    if (!isValidLength) return 'Invalid phone number';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final effectiveLabelStyle = widget.labelStyle ?? theme.textTheme.muted;
    return ShadInputFormField(
      id: widget.id,
      initialValue: widget.initialValue?.number,
      leading: FlagsDropDown(
        flagWidth: 18,
        countryCodeDisable: true,
        dropdownIconPosition: Position.trailing,
        countries: countries,
        initialCountryCode: widget.initialCountryCode,
        pickerDialogStyle: PickerDialogStyle(width: 320),
        onCountryChanged: (value) => setState(() => _selectedCountry = value),
      ),
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.number,
      label: widget.label != null
          ? DefaultTextStyle(style: effectiveLabelStyle, child: widget.label!)
          : null,
      placeholder: widget.placeholder,
      onChanged: _onChanged,
      validator: _validateSync,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
    );
  }
}

bool isNumeric(String s) {
  return s.isNotEmpty && int.tryParse(s.replaceAll('+', '')) != null;
}
