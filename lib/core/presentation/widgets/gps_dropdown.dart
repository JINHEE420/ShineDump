import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

import '../../../utils/style.dart';

typedef AppDropDownOptionToString<T> = String Function(T? option);

class GpsDropDown<T> extends StatefulWidget {
  const GpsDropDown({
    super.key,
    required this.items,
    required this.displayStringForOption,
    this.title,
    this.titleStyle,
    this.hintText = '',
    this.hintStyle,
    this.hintCenter = false,
    this.enabled = true,
    this.bgColor,
    this.border,
    this.controller,
    this.onTap,
    this.onChanged,
    this.validator,
    this.value,
    this.errorText,
    this.alignContext = Alignment.centerLeft,
    this.borerColor,
    this.icon,
    this.height = 50,
    this.borderRadius = 4,
    this.contentPadding,
    this.valueStyle,
    this.customButton,
    this.errorColor,
    this.textSize,
    this.textHeightLine,
    this.textPadding,
    this.iconPadding,
    this.textStyle,
    this.footer,
  });

  final T? value;
  final String? errorText;
  final Color? errorColor;
  final String? title;
  final TextStyle? titleStyle;
  final TextStyle? hintStyle;
  final List<T> items;
  final String hintText;
  final bool hintCenter;
  final bool enabled;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final AppDropDownOptionToString<T> displayStringForOption;
  final AlignmentGeometry? alignContext;
  final Color? borerColor;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final EdgeInsets? contentPadding;
  final TextStyle? valueStyle;
  final Widget? customButton;
  final Color? bgColor;
  final InputBorder? border;
  final double? textSize;
  final double? textHeightLine;
  final EdgeInsets? textPadding;
  final EdgeInsets? iconPadding;
  final TextStyle? textStyle;
  final Widget? footer;

  @override
  State<GpsDropDown<T>> createState() => _GpsDropDownState<T>();
}

class _GpsDropDownState<T> extends State<GpsDropDown<T>> {
  List<T> items = [];
  T? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    items.clear();
    items.addAll(widget.items);
    selectedValue = widget.value;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant GpsDropDown<T> oldWidget) {
    if (widget.items != oldWidget.items || widget.value != oldWidget.value) {
      items.clear();
      items.addAll(widget.items);
      selectedValue = widget.value;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.title!,
              style: widget.titleStyle ??
                  gpsTextStyle(
                    weight: FontWeight.w500,
                    fontSize: 14,
                    lineHeight: 20,
                    // color: DncColors.vampireGrey,
                  ),
            ),
          )
        ],
        DropdownButtonHideUnderline(
          child: SizedBox(
            height: widget.height,
            child: DropdownButtonFormField2<T>(
              isExpanded: false,
              // footer: widget.footer,
              style: widget.valueStyle?.copyWith(fontSize: 1),
              items: _addDividersAfterItems(widget.items),
              onChanged: widget.enabled
                  ? (value) {
                      widget.onChanged?.call(value);
                      setState(
                        () {
                          selectedValue = null;
                          selectedValue = value;
                        },
                      );
                    }
                  : null,
              value: selectedValue,
              selectedItemBuilder: selectedValue == null
                  ? null
                  : (context) {
                      return _addDividersAfterItems(items).map(
                        (e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              widget.displayStringForOption(selectedValue),
                              style: widget.textStyle ??
                                  TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: widget.textSize ?? 16,
                                    height: (widget.textHeightLine ?? 19) /
                                        (widget.textSize ?? 16),
                                  ),
                            ),
                          );
                        },
                      ).toList();
                    },
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.hintText,
                  style: widget.hintStyle ??
                      gpsTextStyle(
                        weight: FontWeight.w600,
                        fontSize: widget.textSize ?? 16,
                        lineHeight: widget.textHeightLine ?? 19,
                        color: Colors.blueGrey,
                      ),
                ),
              ),
              // customButton: widget.customButton,
              isDense: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              iconStyleData: IconStyleData(
                icon: Padding(
                  padding:
                      widget.iconPadding ?? const EdgeInsets.only(right: 16.0),
                  child: widget.icon ?? const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              buttonStyleData: ButtonStyleData(
                padding: EdgeInsets.zero,
                height: widget.height,
                decoration: BoxDecoration(
                  color: widget.bgColor ?? Colors.white,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    width: 1.0,
                    color: widget.borerColor ?? Colors.grey,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.05),
                    )
                  ],
                ),
                width: double.infinity,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              menuItemStyleData: MenuItemStyleData(
                customHeights: _getCustomItemsHeights(),
                padding: EdgeInsets.zero,
                selectedMenuItemBuilder: (_, child) {
                  return Container(
                    color: Colors.blue[50],
                    child: child,
                  );
                },
              ),
              validator: widget.validator,
              // padding: EdgeInsets.all(10),
            ),
          ),
        ),
        Visibility(
          visible: widget.errorText != null,
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorText ?? "",
              style: gpsTextStyle(
                weight: FontWeight.w500,
                fontSize: 14,
                lineHeight: 20,
                color: widget.errorColor ?? Colors.grey,
              ),
            ),
          ),
        )
      ],
    );
  }

  List<DropdownMenuItem<T>> _addDividersAfterItems(List<T> items) {
    List<DropdownMenuItem<T>> menuItems = [];
    for (var item in items) {
      menuItems.addAll(
        [
          DropdownMenuItem<T>(
            value: item,
            child: Padding(
              padding: widget.textPadding ??
                  const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.displayStringForOption(item),
                style: gpsTextStyle(
                  weight: FontWeight.w500,
                  fontSize: widget.textSize ?? 14,
                  lineHeight: widget.textHeightLine ?? 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          if (item != items.last)
            DropdownMenuItem(
              enabled: false,
              child: Divider(
                thickness: 1,
                height: 1,
                color: Colors.grey,
              ),
            ),
        ],
      );
    }
    return menuItems;
  }

  List<double> _getCustomItemsHeights() {
    List<double> itemsHeights = [];
    for (var i = 0; i < (items.length * 2) - 1; i++) {
      if (i.isEven) {
        itemsHeights.add(50);
      }
      //Dividers indexes will be the odd indexes
      if (i.isOdd) {
        itemsHeights.add(1);
      }
    }
    return itemsHeights;
  }
}
