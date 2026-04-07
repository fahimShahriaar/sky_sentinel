import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class RequestLocationPermission extends LocationEvent {
  const RequestLocationPermission();
}

class FetchCurrentLocation extends LocationEvent {
  const FetchCurrentLocation();
}
