import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String text1;
  final String? text2, text3, text4, text5;
  final TextStyle? style1, style2, style3, style4, style5;
  final TextStyle? style;
  final GestureTapCallback? onTap1, onTap2, onTap3, onTap4, onTap5, onTap;
  final TextAlign textAlign;
  final int? maxLines;
  final Widget? prefix, suffix;
  final double prefixDistance, suffixDistance, splashRadius;
  final CrossAxisAlignment? crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const CustomRichText({
    super.key,
    required this.text1,
    this.text2,
    this.text3,
    this.text4,
    this.text5,
    this.style,
    this.style1,
    this.style2,
    this.style3,
    this.style4,
    this.style5,
    this.onTap,
    this.onTap1,
    this.onTap2,
    this.onTap3,
    this.onTap4,
    this.onTap5,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.prefix,
    this.suffix,
    this.prefixDistance = 10,
    this.suffixDistance = 10,
    this.splashRadius = 8,
    this.crossAxisAlignment,
    this.padding,
  });

  TextStyle get _style => TextStyle(fontSize: 13.5, color: Colors.black, height: 1.01);

  TextStyle get _masterStyle => style ?? _style;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(splashRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              prefix ?? const SizedBox.shrink(),
              SizedBox(width: prefix != null ? prefixDistance : 0),
              Flexible(
                child: RichText(
                  maxLines: maxLines,
                  textAlign: textAlign,
                  overflow: TextOverflow.visible,
                  text: TextSpan(
                    style: _masterStyle,
                    children: <InlineSpan>[
                      TextSpan(text: text1, style: style1 ?? _masterStyle, recognizer: TapGestureRecognizer()..onTap = onTap1),
                      TextSpan(text: text2, style: style2 ?? _masterStyle, recognizer: TapGestureRecognizer()..onTap = onTap2),
                      TextSpan(text: text3, style: style3 ?? _masterStyle, recognizer: TapGestureRecognizer()..onTap = onTap3),
                      TextSpan(text: text4, style: style4 ?? _masterStyle, recognizer: TapGestureRecognizer()..onTap = onTap4),
                      TextSpan(text: text5, style: style5 ?? _masterStyle, recognizer: TapGestureRecognizer()..onTap = onTap5),
                    ],
                  ),
                ),
              ),
              SizedBox(width: suffix != null ? suffixDistance : 0),
              suffix ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
