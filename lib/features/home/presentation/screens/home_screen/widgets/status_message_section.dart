part of '../home_screen_compact.dart';

/// A widget that displays the status message section on the home screen.
///
/// This section includes a title, a trip action button, and a message
/// prompting the user to press the button when they arrive.
class StatusMessageSection extends StatelessWidget {
  const StatusMessageSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
          ),
          child: Row(
            // title
            children: [
              Assets.icons.icPlace.image(),
              const SizedBox(width: 10),
              Text(
                tr(context).statusMessage,
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 50,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
          ),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TripActionButton(),
              const SizedBox(height: 20),
              Text(
                tr(context).pressButtonWhenArrived,
                style: gpsTextStyle(
                  weight: FontWeight.w700,
                  fontSize: 15,
                  lineHeight: 20.4,
                  color: const Color(0xFF352555),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A widget that handles the trip action button logic and UI.
///
/// This widget determines the button's color, behavior, and state based on
/// the current trip status, such as whether the user can drive, is moving,
/// or is close to the unloading area.
class TripActionButton extends ConsumerWidget {
  const TripActionButton({super.key});

  /// Handles the logic when the trip button is pressed.
  ///
  /// Depending on the trip state, it may navigate to the map screen,
  /// show a dialog, or request location permissions.
  Future<void> _handleTripButtonPressed(
    BuildContext context, {
    bool canDrive = false,
    bool moving = false,
    bool isClosedToUnloading = false,
  }) async {
    if (isClosedToUnloading) {
      await AppDialog.showDialog(
        context,
        const AfterEndTripWidgetOptions(),
        maxHeight: MediaQuery.of(context).size.height * .375,
      );
    } else if (canDrive && !moving) {
      if (await _isLocationPermissionGranted(context)) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (context) => const TripCreationScreen()),
        );
      }
    }
  }

  /// Checks if location permissions are granted.
  ///
  /// If permissions are denied, it requests them or prompts the user to
  /// open the app settings.
  Future<bool> _isLocationPermissionGranted(BuildContext context) async {
    var result = await Geolocator.checkPermission();

    /// check location permisson first
    // Do ở android không phân biệt được denied và deniedForever nên phải request lại
    // Nếu deniedForever thì sẽ hiện dialog để mở setting
    if (result == LocationPermission.denied) {
      result = await Geolocator.requestPermission(); // Request again
      if (result == LocationPermission.denied) {
        return false;
      }
    }
    if (result == LocationPermission.deniedForever) {
      if (!context.mounted) return false;
      await showGeneralDialog(
        context: context,
        barrierLabel: 'barrier',
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => AlertDialog(
          title: Text(tr(context).locationPerisstionTitle),
          content: Text(tr(context).locationPerisstionMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(tr(context).openSettings),
            ),
          ],
        ),
      );
      return false;
    }

    // Check if permission is adequate for the app's needs
    return result == LocationPermission.whileInUse ||
        result == LocationPermission.always;
  }

  /// Determines the button color based on the trip state.
  ///
  /// - Orange: Close to unloading.
  /// - Blue: Ready to start driving.
  /// - Grey: Disabled or moving.
  Color _getButtonColor({
    bool canDrive = false,
    bool moving = false,
    bool isClosedToUnloading = false,
  }) {
    if (isClosedToUnloading) {
      return const Color(0xFFF48724); // Orange for unloading
    }
    if (moving) {
      return Colors.grey;
    }
    if (canDrive) {
      return const Color(0xFF1E386D); // Blue for starting
    }

    return Colors.grey; // Disabled state
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasProjectProvider =
        ref.watch(projectStateProvider.select((s) => s.isSome()));
    final hasLoadAreaProvider =
        ref.watch(areaLoadingStateProvider.select((s) => s.isSome()));
    final hasUnloadAreaProvider =
        ref.watch(areaUnLoadingStateProvider.select((s) => s.isSome()));
    final unloadArea = ref.watch(
      tripManagerProvider.select((s) => s.toNullable()?.trip?.unloadingArea),
    );

    final canDrive =
        hasProjectProvider && hasLoadAreaProvider && hasUnloadAreaProvider;
    final moving = ref
        .watch(tripManagerProvider.select((s) => s.toNullable()?.trip != null));
    final distanceToUnloadingDestination = ref.watch(
      tripManagerProvider
          .select((s) => s.toNullable()?.distanceToUnloadingDestination),
    );
    final distance = ref.watch(
      tripManagerProvider.select((s) => s.toNullable()?.distance),
    );
    final isClosedToUnloading = distanceToUnloadingDestination != null &&
        unloadArea != null &&
        distanceToUnloadingDestination < 300 + unloadArea.radius;

    logger.log(
      'canDrive: $canDrive, moving: $moving, isClosedToUnloading: $isClosedToUnloading, distance: ${distance}m',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr(context).basicMode,
          style: gpsTextStyle(
            weight: FontWeight.w700,
            fontSize: 15,
            lineHeight: 20.4,
            color: const Color(0xFF352555),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          height: 100,
          child: Stack(
            children: [
              Align(
                child: TripButton(
                  onPressed: () => _handleTripButtonPressed(
                    context,
                    canDrive: canDrive,
                    moving: moving,
                    isClosedToUnloading: isClosedToUnloading,
                  ),
                  color: _getButtonColor(
                    canDrive: canDrive,
                    moving: moving,
                    isClosedToUnloading: isClosedToUnloading,
                  ),
                  text: !moving
                      ? (canDrive ? tr(context).drive : '대기')
                      : tr(context).unload,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: DistanceDisplay(distance: distance?.toKm() ?? 0),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A circular button widget used for trip actions.
///
/// Displays a text label and changes its appearance based on the provided
/// color and state.
class TripButton extends StatelessWidget {
  const TripButton({
    required this.onPressed,
    required this.color,
    required this.text,
    super.key,
  });

  /// Callback triggered when the button is pressed.
  final VoidCallback onPressed;

  /// The background color of the button.
  final Color color;

  /// The text displayed on the button.
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: gpsTextStyle(
            weight: FontWeight.w700,
            fontSize: 32,
            lineHeight: 43,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// A widget that displays the distance to the destination.
///
/// The distance is shown in kilometers with a styled text format.
class DistanceDisplay extends StatelessWidget {
  const DistanceDisplay({
    required this.distance,
    super.key,
  });

  /// The distance to display, in kilometers.
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: distance.toStringAsFixed(2),
        style: gpsTextStyle(
          weight: FontWeight.w700,
          fontSize: 25,
          lineHeight: 30,
          color: const Color(0xFF352555),
        ),
        children: [
          TextSpan(
            text: 'km',
            style: gpsTextStyle(
              weight: FontWeight.w700,
              fontSize: 15,
              lineHeight: 20.4,
              color: const Color(0xFF352555),
            ),
          ),
        ],
      ),
    );
  }
}
