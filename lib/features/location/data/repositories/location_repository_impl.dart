import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;

  LocationRepositoryImpl({required this.dataSource});

  @override
  Future<Position> getCurrentPosition() async {
    return await dataSource.getCurrentPosition();
  }

  @override
  Future<bool> requestPermission() async {
    return await dataSource.requestPermission();
  }

  @override
  Future<bool> isPermissionGranted() async {
    return await dataSource.isPermissionGranted();
  }
}
