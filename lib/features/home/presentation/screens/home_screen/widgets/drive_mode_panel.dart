part of '../home_screen_compact.dart';

/// A widget that represents the drive mode selection panel.
class DriveModePanel extends ConsumerWidget {
  /// Creates a [DriveModePanel].
  const DriveModePanel({super.key});

  void _onDriveModeSelected(
    BuildContext context,
    WidgetRef ref,
    DriveMode mode,
  ) {
    AppDialog.showDialog(
      context,
      DriveModeConfirmDialog(
        message: mode == DriveMode.smart
            ? tr(context).enableSmartModeMessage
            : tr(context).enableNormalModeMessage,
        onConfirm: () {
          ref.read(driveModeStateProvider.notifier).setDriveMode(mode);
          AppDialog.closeDialog(context);
        },
      ),
      maxHeight: 190,
      isShowClose: false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize selected mode state from arguments
    final selectedMode =
        ref.watch(driveModeStateProvider.select((p) => p.toNullable()));

    // Check if the trip is in progress
    // and disable the button if it is
    final moving = ref
        .watch(tripManagerProvider.select((s) => s.toNullable()?.trip != null));

    return Column(
      children: [
        Text(
          tr(context).drivingMode,
          style: gpsTextStyle(
            weight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ButtonMode(
                  isSelected: selectedMode == DriveMode.normal,
                  onPressed: moving
                      ? null
                      : () {
                          if (selectedMode == DriveMode.normal) {
                            return;
                          }
                          _onDriveModeSelected(
                            context,
                            ref,
                            DriveMode.normal,
                          );
                        },
                  title: tr(context).normalMode,
                ),
              ),
              Expanded(
                child: ButtonMode(
                  isSelected: selectedMode == DriveMode.smart,
                  onPressed: moving
                      ? null
                      : () {
                          if (selectedMode == DriveMode.smart) {
                            return;
                          }
                          _onDriveModeSelected(
                            context,
                            ref,
                            DriveMode.smart,
                          );
                        },
                  title: tr(context).smartMode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A widget that represents a mode is selected.
class ButtonMode extends StatelessWidget {
  /// Creates a [ButtonMode].
  const ButtonMode({
    required this.onPressed,
    required this.title,
    required this.isSelected,
    super.key,
  });

  final bool isSelected;
  final VoidCallback? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              disabledBackgroundColor: Color(int.parse('0xFF1E376D')),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              title,
              style: gpsTextStyle(
                weight: FontWeight.w400,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          )
        : TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(
              title,
              style: gpsTextStyle(
                weight: FontWeight.w400,
                fontSize: 14,
                color: Color(int.parse('0xFFB3BCCE')),
              ),
            ),
          );
  }
}

/// A confirmation dialog for activating smart mode.
class DriveModeConfirmDialog extends StatelessWidget {
  /// Creates a [DriveModeConfirmDialog].
  const DriveModeConfirmDialog({
    required this.onConfirm,
    required this.message,
    super.key,
  });

  /// Callback when user confirms the action
  final VoidCallback onConfirm;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Text(
                message,
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(int.parse('0xFFB3BCCE')),
                      side: const BorderSide(
                        color: Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () {
                      AppDialog.closeDialog(context);
                    },
                    child: Text(
                      tr(context).cancelButton,
                      style: gpsTextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.transparent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      shadowColor: Colors.transparent,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(
                      tr(context).confirmButton,
                      style: gpsTextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
