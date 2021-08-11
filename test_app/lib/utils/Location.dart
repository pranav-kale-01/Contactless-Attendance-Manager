import 'package:geolocator/geolocator.dart';

class Location {
  Future<Map<String, String>> getLocation() async {
    Position position = await Geolocator.getCurrentPosition( desiredAccuracy: LocationAccuracy.high );
    Map<String, String> temp = {};
    temp['lat'] = position.latitude.toString();
    temp['lon'] = position.longitude.toString();

    return temp;
  }
}