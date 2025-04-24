import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppOverLay {
  static OverlayEntry? _overlayEntry;

  static void showOverlay(
    BuildContext context, {
    required String title,
    required Widget content,
    double? minWidth,
    Color? backgroundColor,
    bool showCloseIcon = true,
    Alignment? alignment,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    // Create an OverlayEntry
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _removeOverlay(context), // Dismiss when tapping outside
          child: Stack(
            alignment: alignment ?? Alignment.topCenter,
            children: [
              Positioned(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black.withOpacity(.3),
                ),
              ),
              Positioned(
                left: left,
                right: right,
                top: top,
                bottom: bottom,
                child: SizedBox(
                  width: minWidth ?? MediaQuery.of(context).size.width * .5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: backgroundColor,
                        child: content,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Insert the OverlayEntry
    Overlay.of(context).insert(_overlayEntry!);
  }

  static void _removeOverlay(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null; // Clean up to allow re-adding

    FocusScope.of(context).unfocus();
  }

  static void closeOverlay(BuildContext context) => _removeOverlay(context);
}

class AppDialog {
  static Future<Object?> showDialog(
    BuildContext context,
    Widget child, {
    double? maxHeight,
    bool isShowClose = true,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierLabel: 'Barrier',
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (context, animation, secondaryAnimation) => Dialog(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? MediaQuery.of(context).size.height * .5,
            ),
            child: Column(
              children: [
                ...isShowClose
                    ? [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              child: const Icon(Icons.close),
                              onTap: () {
                                context.pop();
                              },
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ]
                    : [],
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void closeDialog(BuildContext context) {
    Navigator.of(context).maybePop();
  }
}
