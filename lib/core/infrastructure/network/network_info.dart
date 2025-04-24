import 'package:connectivity_plus/connectivity_plus.dart';

import '../../presentation/utils/riverpod_framework.dart';
import 'data_connection_checker.dart';

part 'network_info.g.dart';

/// Provides a Riverpod provider for [NetworkInfo].
///
/// This provider is kept alive for the entire app lifecycle.
@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) {
  return NetworkInfo(
    DataConnectionChecker(),
    Connectivity(),
  );
}

/// A utility class to check network connectivity and internet availability.
///
/// [NetworkInfo] provides methods to check both the device's network connectivity
/// status as well as actual internet connection availability.
///
/// Usage:
/// ```dart
/// final networkInfo = ref.watch(networkInfoProvider);
/// final hasInternet = await networkInfo.hasInternetConnection;
/// final connectivityType = await networkInfo.hasNetworkConnectivity;
/// ```
class NetworkInfo {
  /// Creates a [NetworkInfo] instance with required dependencies.
  ///
  /// [dataConnectionChecker] - Used to check actual internet connectivity.
  /// [connectivity] - Used to determine the type of network connection.
  NetworkInfo(this.dataConnectionChecker, this.connectivity);

  /// Instance of [DataConnectionChecker] for checking internet connectivity.
  final DataConnectionChecker dataConnectionChecker;

  /// Instance of [Connectivity] for checking network connection type.
  final Connectivity connectivity;

  /// Checks if the device has an active internet connection.
  ///
  /// Returns a [Future<bool>] that resolves to:
  /// - `true` if internet is available
  /// - `false` if internet is not available
  Future<bool> get hasInternetConnection => dataConnectionChecker.hasConnection;

  /// Determines the current network connectivity type.
  ///
  /// Returns a [Future<ConnectivityResult>] that can be one of:
  /// - [ConnectivityResult.wifi] - Connected via WiFi
  /// - [ConnectivityResult.mobile] - Connected via mobile data
  /// - [ConnectivityResult.ethernet] - Connected via ethernet
  /// - [ConnectivityResult.bluetooth] - Connected via bluetooth
  /// - [ConnectivityResult.none] - No connectivity
  Future<ConnectivityResult> get hasNetworkConnectivity =>
      connectivity.checkConnectivity();
}
