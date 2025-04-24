import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/style.dart';

class GpsTextField extends StatelessWidget {
  const GpsTextField(
      {super.key,
      this.controller,
      this.onChanged,
      this.keyboardType,
      this.focusNode,
      this.hintText,
      this.hintStyle,
      this.hintColor,
      this.bgColor,
      this.borderColor,
      this.title,
      this.titleStyle,
      this.errorText,
      this.readOnly = false,
      this.isLastFieldOfPage,
      this.obscureText,
      this.inputFormatters,
      this.textCapitalization,
      this.textAlign = TextAlign.left,
      this.suffixIcon,
      this.contentPadding,
      this.prefix,
      this.textStyle,
      this.errorColor,
      this.border,
      this.errorBorder,
      this.suffixIconConstraints,
      this.cursorColor,
      this.minLines,
      this.maxLines = 1,
      this.textInputAction,
      this.onSubmitted,
      this.onEditingComplete,
      this.maxLength,
      this.expand = false,
      this.isDense = false,
      this.enableEdit = true});

  final TextEditingController? controller;
  final Function(String value)? onChanged;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final String? hintText;
  final Color? hintColor;
  final Color? bgColor;
  final Color? borderColor;
  final String? title;
  final TextStyle? titleStyle;
  final String? errorText;
  final Color? errorColor;
  final bool? readOnly;
  final bool? isLastFieldOfPage;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization? textCapitalization;
  final TextAlign? textAlign;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? prefix;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final int? minLines;
  final int? maxLines;
  final BoxConstraints? suffixIconConstraints;
  final InputBorder? border;
  final InputBorder? errorBorder;
  final Color? cursorColor;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final Function(String value)? onSubmitted;
  final Function(String value)? onEditingComplete;
  final bool isDense;
  final bool expand;

  final bool enableEdit;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      enabled: enableEdit,
      expands: expand,
      focusNode: focusNode,
      readOnly: readOnly ?? false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization ?? TextCapitalization.words,
      controller: controller,
      cursorColor: cursorColor ?? Colors.blueGrey,
      style: textStyle ??
          gpsTextStyle(weight: FontWeight.w500, fontSize: 18, lineHeight: 21)
              .copyWith(
            decoration: TextDecoration.none,
          ),
      textAlign: textAlign ?? TextAlign.left,
      textAlignVertical: TextAlignVertical.top,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        if (onEditingComplete != null) {
          onEditingComplete?.call(controller?.text ?? '');
        }
      },
      cursorWidth: 0.75,
      autocorrect: false,
      enableSuggestions: false,
      obscureText: obscureText ?? false,
      obscuringCharacter: '*',
      maxLines: expand ? null : maxLines,
      minLines: expand ? null : minLines,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction ??
          ((isLastFieldOfPage ?? false)
              ? TextInputAction.done
              : TextInputAction.next),
      decoration: InputDecoration(
        isDense: isDense,
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 16, left: 12),
                child: prefix,
              ),
        hintText: hintText,
        suffixIcon: suffixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: 8),
                child: suffixIcon,
              ),
        suffixIconConstraints: suffixIconConstraints,
        hintStyle: hintStyle ??
            gpsTextStyle(
              weight: FontWeight.w500,
              fontSize: 18,
              lineHeight: 21,
              color: hintColor ?? Colors.grey,
            ).copyWith(
              decoration: TextDecoration.none,
            ),
        enabledBorder: border ??
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: borderColor ?? Colors.blueGrey,
                )),
        focusedBorder: (border ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.blueGrey,
                    )))
            .copyWith(
                borderSide: border?.borderSide
                    .copyWith(color: borderColor ?? Colors.blueGrey)),
        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
        disabledBorder: border ??
            OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(color: borderColor ?? Colors.blueGrey)),
        filled: true,
        fillColor: bgColor ?? Colors.white,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
      ),
    );

    if (expand) {
      return field;
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: title != null,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                title ?? "",
                style: titleStyle ??
                    gpsTextStyle(
                      weight: FontWeight.w500,
                      fontSize: 14,
                      lineHeight: 20,
                      color: Colors.grey,
                    ),
              ),
            ),
          ),
          field,
          Visibility(
            visible: errorText != null,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                errorText ?? "",
                style: gpsTextStyle(
                  weight: FontWeight.w500,
                  fontSize: 14,
                  lineHeight: 20,
                  color: errorColor ?? Colors.grey,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
