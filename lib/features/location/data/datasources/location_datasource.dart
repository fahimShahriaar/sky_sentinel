import 'package:geolocator/geolocator.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';

abstract class LocationDataSource {
  Future<Position> getCurrentPosition();
  Future<bool> requestPermission();
  Future<bool> isPermissionGranted();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<Position> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(message: 'Location services are disabled. Please enable them.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const LocationException(message: 'Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(message: 'Location permissions are permanently denied. Please enable them in settings.');
      }

      appLogger.i('Getting current position...');

      // Try last known position first (instant, works on emulators)
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        appLogger.i('Using last known position: ${lastKnown.latitude}, ${lastKnown.longitude}');
        // Still request a fresh fix in the background for next time,
        // but return the cached position immediately.
        Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 30)),
        ).ignore();
        return lastKnown;
      }

      // No cached position available — must wait for a fresh fix
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 30)),
      );
      appLogger.i('Position obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } on LocationException {
      rethrow;
    } catch (e) {
      appLogger.e('Error getting location: $e');
      throw LocationException(message: 'Failed to get location: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }
}
