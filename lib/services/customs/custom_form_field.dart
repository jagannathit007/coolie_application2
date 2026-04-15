import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CustomFormField extends StatefulWidget {
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool readOnly;
  final void Function()? onTap;
  final ValueChanged<String>? onSubmit;
  final TextInputAction? textInputAction;
  final Widget? prefix, suffix;
  final bool obscureText;
  final bool isRequiredMark;
  final Color? fillColor;
  final TextStyle? titleStyle, style;
  final TextAlign textAlign;
  final void Function(String)? onChanged;
  final EdgeInsets? contentPadding;
  final BoxConstraints? constraints;
  final bool? enabled;
  final double borderRadius;
  final double hintFontSize;
  final bool isPasswordField;
  final bool isDateField;
  final bool? borderEnabled;
  final TextCapitalization textCapitalization;

  const CustomFormField({
    super.key,
    this.titleStyle,
    this.style,
    this.initialValue,
    this.inputFormatters,
    this.controller,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.onSubmit,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.isRequiredMark = false,
    this.fillColor = Colors.white,
    this.textAlign = TextAlign.start,
    this.onChanged,
    this.contentPadding,
    this.constraints,
    this.enabled,
    this.hintFontSize = 15,
    this.borderRadius = 10.0,
    this.isPasswordField = false,
    this.isDateField = false,
    this.borderEnabled = false,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  CustomFormFieldState createState() => CustomFormFieldState();
}

class CustomFormFieldState extends State<CustomFormField> {
  bool _isObscured = true;

  void _toggleObscureText() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(onPrimary: Colors.white, onSurface: Colors.black),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom()),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      widget.controller?.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          enabled: widget.enabled,
          textCapitalization: widget.textCapitalization,
          initialValue: widget.initialValue,
          controller: widget.controller,
          cursorColor: Colors.black,
          validator: (value) {
            final trimmedValue = value?.trim() ?? '';
            if (widget.isRequiredMark && trimmedValue.isEmpty) {
              return null;
            }
            if (widget.validator != null) {
              return widget.validator!(value);
            }
            return null;
          },
          minLines: 1,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          textAlign: widget.textAlign,
          keyboardType: widget.isDateField ? TextInputType.none : widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          readOnly: widget.isDateField ? true : widget.readOnly,
          onTap: widget.isDateField ? () => _selectDate(context) : widget.onTap,
          onFieldSubmitted: widget.onSubmit,
          obscureText: widget.isPasswordField ? _isObscured : widget.obscureText,
          onChanged: widget.onChanged,
          style: widget.style ?? const TextStyle(fontSize: 13, color: Colors.black),
          decoration: InputDecoration(
            fillColor: widget.fillColor,
            filled: true,
            counterText: "",
            prefixIcon: widget.prefix,
            suffixIcon:
                widget.suffix ??
                (widget.isPasswordField
                    ? IconButton(
                        icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: _toggleObscureText,
                      )
                    : widget.isDateField
                    ? const Icon(Icons.calendar_today, color: Colors.grey)
                    : null),
            contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            isDense: true,
            constraints: widget.constraints ?? const BoxConstraints(maxHeight: 300, minHeight: 40),
            hintText: widget.hintText,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(color: Colors.black, fontSize: widget.hintFontSize),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: (widget.borderEnabled ?? true) ? Colors.black : Colors.transparent, width: 0.5),
            ),
            errorMaxLines: 1,
            errorStyle: TextStyle(fontSize: 12, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
