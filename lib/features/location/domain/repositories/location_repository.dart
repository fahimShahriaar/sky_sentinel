import 'package:geolocator/geolocator.dart';

abstract class LocationRepository {
  Future<Position> getCurrentPosition();
  Future<bool> requestPermission();
  Future<bool> isPermissionGranted();
}
