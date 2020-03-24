import 'package:flutter_background_location/flutter_background_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

typedef void OnLocationUpdate(LatLng latLng);

class LocationService {

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  OnLocationUpdate onLocationUpdate;

  LocationService();

  Location location = new Location();

  LatLng currentLatLng = LatLng(0.0,0.0);

  void enableLocationService () async {

      bool failed = false;
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          failed = true;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.DENIED) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.GRANTED) {
          failed = true;
        }
      }

      if(failed){
        // Colombo is default
        this._handleLocationUpdate(LatLng(6.9271,79.8612));
        return;
      }

      LocationData locationData = await location.getLocation();
      this._handleLocationUpdate(LatLng(locationData.latitude,locationData.longitude));


      FlutterBackgroundLocation.startLocationService();
      FlutterBackgroundLocation.getLocationUpdates((location) {
        this._handleLocationUpdate(LatLng(location.latitude,location.longitude));
      });
  }

  void _handleLocationUpdate( LatLng location){

    if(this.currentLatLng.latitude==location.latitude && this.currentLatLng.longitude == location.longitude){
      return;
    }

    if(this.onLocationUpdate!=null){
      this.onLocationUpdate(location);
    }

    this.currentLatLng = location;
  }

  listen(OnLocationUpdate onLocationUpdate){
    this.onLocationUpdate  = onLocationUpdate;
  }
}