import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextBoxWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final TextInputAction textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  const TextBoxWidget({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.focusNode,
    this.fillColor,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: enabled ? Colors.black87 : Colors.black54),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        counterText: '',
        fillColor: fillColor ?? Colors.grey[50],
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _outlineInputBorder(context),
        enabledBorder: _outlineInputBorder(context),
        focusedBorder: _outlineInputBorder(context).copyWith(borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
        errorBorder: _outlineInputBorder(context).copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.0)),
        focusedErrorBorder: _outlineInputBorder(context).copyWith(borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        disabledBorder: _outlineInputBorder(context).copyWith(borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0)),
        errorStyle: const TextStyle(fontSize: 12, height: 0.8),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(color: enabled ? Colors.black54 : Colors.grey),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
    );
  }
}
