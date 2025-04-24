part of '../home_screen_compact.dart';

/// A custom button widget that triggers a force close action.
///
/// This button is styled with a specific color and text style, and when pressed,
/// it displays a dialog with a `ForceClosePopup` widget. The dialog is non-dismissible
/// unless explicitly closed via the provided callback.
class ForceCloseButton extends StatelessWidget {
  /// Creates a [ForceCloseButton].
  const ForceCloseButton({super.key});

  @override

  /// Builds the widget tree for the force close button.
  ///
  /// The button is wrapped in a container with specific dimensions and margin.
  /// When pressed, it shows a dialog with a `ForceClosePopup`.
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 150,
      height: 50,
      child: CustomElevatedButton(
        padding: const EdgeInsets.symmetric(vertical: 7.5),
        buttonColor: const Color(0xFF4C0506),
        onPressed: () {
          AppDialog.showDialog(
            context,
            ForceClosePopup(
              callback: () {},
            ),
            isShowClose: false,
            barrierDismissible: true,
          );
        },
        child: Text(
          tr(context).forceClose,
          style: gpsTextStyle(
            weight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
