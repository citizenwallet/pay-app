import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/*
// Basic usage
CustomTextField(
  placeholder: 'Enter text',
  onChanged: (value) {
    print('Text changed: $value');
  },
)

// With error state
CustomTextField(
  placeholder: 'Email',
  isError: true,
  errorText: 'Please enter a valid email',
  keyboardType: TextInputType.emailAddress,
)

// Password field
CustomTextField(
  placeholder: 'Password',
  obscureText: true,
  suffix: Icon(CupertinoIcons.eye),
)

// Multiline text area
CustomTextField(
  placeholder: 'Description',
  maxLines: null,
  minLines: 3,
  textAlignVertical: TextAlignVertical.top,
)

// With label
CustomTextField(
  label: 'Username',
  placeholder: 'Enter your username',
)

// Disabled state
CustomTextField(
  placeholder: 'Disabled field',
  enabled: false,
)

*/

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? label;
  final bool isError;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool autocorrect;
  final bool enableSuggestions;
  final Widget? prefix;
  final Widget? suffix;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final TextAlignVertical? textAlignVertical;
  final TextAlign? textAlign;
  final BorderRadius? borderRadius;
  final List<TextInputFormatter>? inputFormatters;

  CustomTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.label,
    this.isError = false,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.prefix,
    this.suffix,
    this.decoration,
    this.padding,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.placeholderStyle,
    this.textAlignVertical,
    this.textAlign,
    this.borderRadius,
    this.inputFormatters,
  });

  final EdgeInsetsGeometry defaultPadding =
      const EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  final defaultBorderRadius = BorderRadius.circular(100);

  final defaultPlaceholderStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFB7ADC4),
  );

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    final BoxDecoration defaultDecoration = BoxDecoration(
      border: Border.all(
        color: isError ? CupertinoColors.systemRed : theme.primaryColor,
        width: 2,
      ),
      borderRadius: borderRadius ?? defaultBorderRadius,
      color: enabled ? CupertinoColors.white : CupertinoColors.systemGrey6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          textInputAction: textInputAction,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          prefix: prefix,
          suffix: suffix,
          padding: padding ?? defaultPadding,
          textCapitalization: textCapitalization,
          style: style,
          placeholderStyle: placeholderStyle ?? defaultPlaceholderStyle,
          textAlignVertical: textAlignVertical,
          textAlign: textAlign ?? TextAlign.start,
          decoration: decoration ?? defaultDecoration,
          inputFormatters: inputFormatters,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
        ),
        if (isError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: CupertinoColors.systemRed,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
