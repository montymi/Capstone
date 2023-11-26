part of 'map_bloc.dart';

abstract class MapState {
  LatLng coordinates;
  MapState({required this.coordinates});
}

class MapInitial extends MapState {
  MapInitial({required LatLng coordiantes}) : super(coordinates: coordiantes);
}

class MapUpdated extends MapState {
  MapUpdated({required LatLng coordiantes}) : super(coordinates: coordiantes);
}
