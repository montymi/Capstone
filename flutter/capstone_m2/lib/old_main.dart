import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'blocs/map/map_bloc.dart';

void main() {
  runApp(const MyApp(homeScreen: MapSample()));
}

class MyApp extends StatelessWidget {
  final Widget? homeScreen;
  const MyApp({Key? key, this.homeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (context) => MapBloc())],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: homeScreen,
        ));
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      setState(() {});
    });
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _northeastern = CameraPosition(
    target: LatLng(42.3404, -71.0888),
    zoom: 17,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M2Solar'),
        backgroundColor: Colors.purple,
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _northeastern,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _initLocation,
        backgroundColor: Colors.purple,
        label: const Text('Locate'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _initLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData? currentLocation = await Location().getLocation();
    CameraPosition newCamera = CameraPosition(
        target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        zoom: 17);
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCamera));
  }
}

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('M2Solar'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapInitial) {
              return getMap(context,
                  state.coordinates); // presents Northeastern coordinates
            } else if (state is MapUpdated) {
              print('Map updated to current location.');
              print(state.coordinates.latitude);
              print(state.coordinates.longitude);
              return getMap(
                  context, state.coordinates); // presents live location
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      );

  Widget getMap(BuildContext context, LatLng coordinates) {
    return Stack(children: [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(coordinates.latitude, coordinates.longitude),
          zoom: 20,
        ),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        // markers: Set<Marker>.of(_markers),
      ),
      Positioned(
          bottom: 20.0,
          right: 20.0,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.purple), // Set the background color to purple
              foregroundColor: MaterialStateProperty.all<Color>(
                  Colors.white), // Set the text color to white)
            ),
            onPressed: () {
              context.read<MapBloc>().add(GetLocation());
            },
            child: const Icon(Icons.my_location),
          ))
    ]);
  }
}

// class _MapPageState extends State<MapPage> {
//   final Completer<GoogleMapController> _googleMapController = Completer();
//   final Location _location = Location();
//   BitmapDescriptor? _customIcon;
//   Set<Marker> _markers = {};

//   @override
//   void initState() {
//     super.initState();
//     initMarkers();
//   }

//   // Future<void> initAsync() async {
//   //   CameraPosition? loc = await initLocation();
//   //   // setState(() {
//   //   //   _customIcon = icon;
//   //   //   _cameraPosition = loc;
//   //   // });
//   //   return Future.value(loc);
//   // }

//   Future<void> initMarkers() async {
//     BitmapDescriptor? icon = BitmapDescriptor.defaultMarker;
//     icon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)),
//       'assets/station_marker_black.png',
//     );
//     setState(() {
//       _customIcon = icon;
//     });
//   }

//   Future<CameraPosition> initLocation() async {
//     if (await checkServiceEnabled() == false) {
//       if (await checkPermissions() == false) {
//         throw Exception('Location services not enabled.');
//       }
//     }
//     double? latitude = 42.3404;
//     double? longitude = -71.0888;

//     LocationData? currentLocation = await _location.getLocation();
//     latitude = currentLocation.latitude;
//     longitude = currentLocation.longitude;
//     print(latitude);
//     print(longitude);

//     CameraPosition position = CameraPosition(
//       target: LatLng(latitude!, longitude!),
//       zoom: 15,
//     );
//     return position;
//   }

//   Future<bool> checkServiceEnabled() async {
//     bool result = true;
//     bool status = await _location.serviceEnabled();
//     if (status == false) {
//       status = await _location.requestService();
//       if (status == false) {
//         result = false;
//       }
//     }
//     return Future.value(result);
//   }

//   Future<bool> checkPermissions() async {
//     bool result = true;
//     PermissionStatus? status = await _location.hasPermission();
//     switch (status) {
//       case PermissionStatus.granted:
//         break;
//       case PermissionStatus.grantedLimited:
//         _location.changeSettings(accuracy: LocationAccuracy.low);
//         break;
//       case PermissionStatus.denied:
//         status = await _location.requestPermission();
//         break;
//       case PermissionStatus.deniedForever:
//         return false;
//       default:
//         throw Exception('Permission status not found.');
//     }
//     return Future.value(result);
//   }

//   Future<void> movePosition(LatLng latLng) async {
//     GoogleMapController mapController = await _googleMapController.future;
//     mapController.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(target: latLng, zoom: 15)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('M2Solar')),
//       body: FutureBuilder<CameraPosition>(
//         future: initLocation(), // Your async function
//         builder:
//             (BuildContext context, AsyncSnapshot<CameraPosition> snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             print(snapshot);
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else {
//             return getMap(snapshot.requireData);
//           }
//         },
//       ),
//     );
//   }

//   Widget getMarker() {
//     return Container(
//       width: 40,
//       height: 40,
//       child: ClipOval(child: Image.asset('assets/station_marker_black.png')),
//     );
//   }

//   Widget getMap(CameraPosition? cameraPosition) {
//     _markers = {
//       Marker(
//           markerId: const MarkerId('station1'),
//           position: const LatLng(42.3404, -71.0888),
//           infoWindow: InfoWindow(title: 'Station 1', snippet: 'Two Ports'),
//           anchor: Offset(0.5, 1.5),
//           rotation: 45.0,
//           visible: true,
//           // onTap: open window screen
//           icon: _customIcon!),
//       Marker(
//         markerId: const MarkerId('station2'),
//         position: const LatLng(42.3385435, -71.0883072),
//         infoWindow: InfoWindow(title: 'Station 2', snippet: 'Two Ports'),
//         anchor: Offset(1.5, 0.5),
//         rotation: 60.0,
//         visible: true,
//         // onTap: open window screen
//         // icon: _customIcon!,
//       ),
//     };
//     GoogleMap test = GoogleMap(
//       initialCameraPosition: cameraPosition!,
//       mapType: MapType.normal,
//       markers: Set<Marker>.of(_markers),
//     );

//     print(test.initialCameraPosition);
//     print(test.mapType);
//     print(test.markers);

//     return GoogleMap(
//       initialCameraPosition: CameraPosition(
//         target: LatLng(42.3404, -71.0888),
//         zoom: 15,
//       ),
//       mapType: MapType.normal,
//       markers: Set<Marker>.of(_markers),
//     );
//   }
// }
