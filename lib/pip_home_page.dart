import 'package:flutter/material.dart';

import 'core/infrastructure/services/local_notifications_service.dart';
import 'core/presentation/utils/riverpod_framework.dart';
import 'features/home/presentation/providers/area_provider/area_provider.dart';
import 'features/home/presentation/providers/project_provider/project_provider.dart';
import 'features/home/presentation/providers/trip_provider/trip_provider.dart';
import 'features/home/presentation/providers/trip_provider/trip_state.dart';
import 'utils/logger.dart';
import 'utils/style.dart';

class PiPHomePage extends StatefulHookConsumerWidget {
  const PiPHomePage({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  ConsumerState<PiPHomePage> createState() => _PiPHomePageState();
}

class _PiPHomePageState extends ConsumerState<PiPHomePage> {
  @override
  void initState() {
    ref.read(localNotificationsServiceProvider).initialization(false);
    super.initState();
  }

  void _endTrip() {
    logger.log('PiPHomePage _endTrip');
  }

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
  Widget build(BuildContext context) {
    logger.log('PiPHomePage build');
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
      'canDrive: $canDrive, moving: $moving, isClosedToUnloading: $isClosedToUnloading, distance: $distance',
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Text(
              '기본 모드 ',
              style: gpsTextStyle(
                weight: FontWeight.w700,
                fontSize: 18,
                lineHeight: 20.4,
                color: const Color(0xFF352555),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: _endTrip,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getButtonColor(
                      canDrive: canDrive,
                      moving: moving,
                      isClosedToUnloading: isClosedToUnloading,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '하차',
                        style: gpsTextStyle(
                          weight: FontWeight.w700,
                          fontSize: 25,
                          lineHeight: 43,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child: Text.rich(
                TextSpan(
                  text: distance?.toKm().toStringAsFixed(2) ?? '0',
                  style: gpsTextStyle(
                    weight: FontWeight.w700,
                    fontSize: 20,
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
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class Filled extends StatelessWidget {
  const Filled({required this.text, super.key, this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Text(text, textAlign: TextAlign.center),
    );
  }
}
