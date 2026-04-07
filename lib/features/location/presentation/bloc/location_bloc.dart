import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository repository;

  LocationBloc({required this.repository}) : super(const LocationInitial()) {
    on<RequestLocationPermission>(_onRequestPermission);
    on<FetchCurrentLocation>(_onFetchCurrentLocation);
  }

  Future<void> _onRequestPermission(RequestLocationPermission event, Emitter<LocationState> emit) async {
    emit(const LocationLoading());
    try {
      final granted = await repository.requestPermission();
      if (granted) {
        add(const FetchCurrentLocation());
      } else {
        emit(const LocationPermissionDenied(message: 'Location permission was denied.'));
      }
    } catch (e) {
      appLogger.e('Error requesting location permission: $e');
      emit(LocationError(message: 'Failed to request permission: $e'));
    }
  }

  Future<void> _onFetchCurrentLocation(FetchCurrentLocation event, Emitter<LocationState> emit) async {
    emit(const LocationLoading());
    try {
      final position = await repository.getCurrentPosition();
      emit(LocationLoaded(latitude: position.latitude, longitude: position.longitude));
    } on LocationException catch (e) {
      if (e.message.contains('permission') || e.message.contains('denied')) {
        emit(LocationPermissionDenied(message: e.message));
      } else {
        emit(LocationError(message: e.message));
      }
    } catch (e) {
      appLogger.e('Error fetching location: $e');
      emit(LocationError(message: 'Failed to get location: $e'));
    }
  }
}
