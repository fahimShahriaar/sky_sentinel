import 'package:equatable/equatable.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final double latitude;
  final double longitude;

  const LocationLoaded({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class LocationPermissionDenied extends LocationState {
  final String message;

  const LocationPermissionDenied({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationError extends LocationState {
  final String message;

  const LocationError({required this.message});

  @override
  List<Object?> get props => [message];
}
