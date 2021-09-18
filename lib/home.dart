import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  LatLng _position = LatLng(31.0425702, 31.3732998);

  _addMarker() {
    _markers.add(Marker(
        markerId: MarkerId('Home'),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'My Location', snippet: 'Handasa'),
        position: _position));
  }

  Future<Position> _getLocation() async {
    LocationPermission permission;
    bool _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location Services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location Permissions are refused');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  _getAddress(double latitude, double longitude) async {
    var instance = GeocodingPlatform.instance;
    try {
      List<Placemark> placeMarks =
      await instance.placemarkFromCoordinates(latitude, longitude);
      Placemark myPlace = placeMarks.first;
      String address = '${myPlace.street} - ${myPlace.name} - ${myPlace
          .country}';
      print('Address $address');
    }catch(e){
      print(e.toString());
    }
  }

  _trackLocation() {
    var instance = location.Location.instance;
    instance.onLocationChanged.listen((event) {
      //event -> LocationData
      print('${event.latitude},${event.longitude}');
      _getAddress(event.latitude!, event.longitude!);
    });
  }

  @override
  Widget build(BuildContext context) {
    _addMarker();
    _trackLocation();
    return Scaffold(
      body: GoogleMap(
        markers: _markers,
        initialCameraPosition: CameraPosition(target: _position, zoom: 11.0),
        mapType: MapType.normal,
        onMapCreated: (controller) {
          _mapController = controller;
          _getLocation().then((value) {
            print(value);
            _getAddress(value.latitude, value.longitude);
          });
        },
      ),
    );
  }
}
