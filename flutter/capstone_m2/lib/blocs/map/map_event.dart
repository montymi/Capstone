part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class GetLocation extends MapEvent {
  GetLocation();
}
