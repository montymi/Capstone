import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
// import '../../models/user.dart';

part 'map_event.dart';
part 'map_state.dart';

const LatLng northeastern = LatLng(42.3404, -71.0888);

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapInitial(coordiantes: northeastern)) {
    on<GetLocation>(_loadCoordinates);
  }

  void _loadCoordinates(GetLocation event, Emitter<MapState> emit) async {
    try {
      final LatLng location = await _initLocation();
      // await controller.animateCamera(CameraUpdate.newCameraPosition(location));
      emit(MapUpdated(coordiantes: location));
    } catch (e) {
      print('$e');
    }
  }

  Future<LatLng> _initLocation() async {
    // if (await checkServiceEnabled() == false) {
    //   if (await checkPermissions() == false) {
    //     throw Exception('Location services not enabled.');
    //   }
    // }
    LocationData? currentLocation = await Location().getLocation();
    return LatLng(currentLocation.latitude!, currentLocation.longitude!);
  }
}
