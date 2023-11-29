import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:m2solar/pages/list_stations_screen.dart';
import 'package:m2solar/models/station.dart';
import 'package:m2solar/pages/user_screen.dart';
import 'package:m2solar/pages/station_screen.dart';


class MapScreen extends StatefulWidget {
  const MapScreen(
      {Key? key}): super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  bool _isLoading = false;
  late Station richards;
  late Station westvillage;
  late Station curry;
  BitmapDescriptor stationMarker = BitmapDescriptor.defaultMarker; 
  late List<Station> stationList; 

  @override
  void initState() {
    _initStations();
    super.initState();
    // _getLocation(); uncomment to auto load in current location
  }

  void _initStations() {
    richards = const Station(
        id: 1,
        name: 'Richards Station',
        latitude: 42.3404,
        longitude: -71.0888,
        ports: 2);
    westvillage = const Station(
        id: 2,
        name: 'West Village',
        latitude: 42.337384,
        longitude: -71.092649,
        ports: 3);
    curry = const Station(
        id: 3,
        name: 'Curry Center',
        latitude: 42.339172,
        longitude: -71.088044,
        ports: 3);
    stationList = <Station>[richards, westvillage, curry];
    BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(), "assets/station_marker_black.png")
      .then((icon) {
        setState(() {
          stationMarker = icon;
        });
      },
    );
  }
  
  void _getLocation() async {
    setState(() {
      _isLoading = true;
    });
    final Location location = Location();
    LocationData? coords;
    if (await _checkLocationSettings(location)) {
      try {
        coords = await Future.any([
          location.getLocation(),
          Future.delayed(const Duration(seconds: 5), () => null),
        ]);
        coords ??= await location.getLocation();
        _updateMapCameraPosition(LatLng(coords.latitude!, coords.longitude!));
      } catch (e) {
        print("Error getting user location: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _checkLocationSettings(Location data) async {
    bool result = true;
    bool serviceStatus = await data.serviceEnabled();
    if (serviceStatus == false) {
      serviceStatus = await data.requestService();
      if (serviceStatus == false) {
        result = false;
        return Future.value(result);
      }
    }
    PermissionStatus? permissionStatus = await data.hasPermission();
    switch (permissionStatus) {
      case PermissionStatus.granted:
        break;
      case PermissionStatus.grantedLimited:
        data.changeSettings(accuracy: LocationAccuracy.low);
        break;
      case PermissionStatus.denied:
        permissionStatus = await data.requestPermission();
        break;
      case PermissionStatus.deniedForever:
        result = false;
      default:
        throw Exception('Permission status not found.');
    }
    return Future.value(result);
  }

  void _updateMapCameraPosition(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 17)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('M2Solar'),
          leading: Padding(
            padding: const EdgeInsets.all(
                0.0), // here to allow for movement of button
            child: FloatingActionButton.extended(
                heroTag: 'station',
                label: const Icon(
                  Icons.ev_station_rounded,
                  size: 30.0,
                ),
                backgroundColor: Colors.transparent,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StationsList(listOfStations: stationList),
                    ));
                }),
          ),
          backgroundColor: Colors.black87,
        ),
        body: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(42.338680165824485, -71.09001238877158),
                  zoom: 16),
              myLocationButtonEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: {
                Marker(
                  markerId: MarkerId(richards.id.toString()),
                  position: LatLng(richards.latitude, richards.longitude),
                  icon: stationMarker,
                  infoWindow: InfoWindow(
                    title: richards.name,
                    snippet: "Click to connect >",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StationScreen(station: richards)),
                      );
                    },
                  ),
                ),
                Marker(
                  markerId: MarkerId(westvillage.id.toString()),
                  position: LatLng(westvillage.latitude, westvillage.longitude),
                  icon: stationMarker,
                  infoWindow: InfoWindow(
                    title: westvillage.name,
                    snippet: "Click to connect >",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StationScreen(station: westvillage)),
                      );
                    },
                  ),
                ),
                Marker(
                  markerId: MarkerId(curry.id.toString()),
                  position: LatLng(curry.latitude, curry.longitude),
                  icon: stationMarker,
                  infoWindow: InfoWindow(
                    title: curry.name,
                    snippet: "Click to connect >",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                StationScreen(station: curry)),
                      );
                    },
                  ),
                ),
              }, // markers
            ),
            // LOCATE BUTTON
            Positioned(
              bottom: 16.0,
              right: 16.0,
              child: FloatingActionButton.extended(
                heroTag: 'location',
                label: const Text("Locate"),
                backgroundColor: Colors.black87,
                onPressed: () {
                  _getLocation();
                },
                icon: const Icon(Icons.my_location, size: 24.0),
              ),
            ),
          ],
        ));
  }
}
