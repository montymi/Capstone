import 'package:location/location.dart';

class MapClass {
  MapClass();
  late LocationData liveCoords;
  double latitude = 42.3404;
  double longitude = -71.0888;
  final int zoom = 17;

  void getLocation() async {
    final Location location = Location();
    if (await _checkLocationSettings(location)) {
      try {
        liveCoords = await Future.any([location.getLocation()]);
        latitude = liveCoords.latitude!;
        longitude = liveCoords.longitude!;
      } catch (e) {
        print("Error getting user location: $e");
      }
    }
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
}
