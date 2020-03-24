
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:safeout/services/http.dart';
import 'package:safeout/services/location.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {

  final LocationService locationService;
  final HttpService httpService;

  MapPage({Key key, this.title, this.httpService, this.locationService}) : super(key: key);

  final String title;

  @override
  _MapPageState createState() => _MapPageState(httpService: this.httpService, locationService: this.locationService);
}

class _MapPageState extends State<MapPage> {

  _MapPageState({this.locationService,this.httpService});

  final LocationService locationService;
  final HttpService httpService;

  List<Marker> markers = List(); 
  BitmapDescriptor homeMarker;
  BitmapDescriptor userMarker;
  
  Completer<GoogleMapController> _mapController = Completer();

  final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(6.9271, 79.8612),
    zoom: 14.0000,
  );

  void _updateLocationAtFirstTime(LatLng latLng) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(latLng));

      if(this.locationService.permissionGranted==PermissionStatus.GRANTED && this.locationService.serviceEnabled){
        this._loadData(this.locationService.currentLatLng);
      }
  }

  void _loadData(LatLng latLng) async {

      List<LatLng> latLngList = await this.httpService.getUserLocations(latLng);

      if(latLngList.length==0){
        Fluttertoast.showToast(
          msg:"No results! :-(",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }

      List<Marker> markers = List();
      int i = 0;

      latLngList.forEach((latLng1){
        MarkerId markerId = MarkerId(i.toString());
        markers.add(Marker(
            markerId: markerId,
            position: latLng1,
            icon: this.userMarker
        ));
        i++;
      });

      final MarkerId markerId = MarkerId(i.toString());

      markers.add(Marker(
        markerId: markerId,
        position: latLng,
        icon: this.homeMarker
      ));

      this.setState((){
        this.markers = markers;
      });
  }

  void initState(){
    super.initState();

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/images/home-marker.png')
        .then((onValue) {
      this.homeMarker = onValue;
    });

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(48, 48)), 'assets/images/user-marker.png')
        .then((onValue) {
      this.userMarker = onValue;
    });

    this._updateLocationAtFirstTime(this.locationService.currentLatLng);

  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: new AppBar(
          title: Text(widget.title),
          leading: Container(),
        ),
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              markers: Set.from(this.markers),
              initialCameraPosition: _initialCamera,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
            Positioned(
              top: 20,
              left: MediaQuery.of(context).size.width * 0.05,
              child: SearchMapPlaceWidget(
                apiKey: FlutterConfig.get("GOOGLE_API_KEY"),
                location: _initialCamera.target,
                radius: 30000,
                onSelected: (place) async {
                  final geolocation = await place.geolocation;

                  final GoogleMapController controller = await _mapController.future;

                  this._loadData(geolocation.coordinates);

                  controller.animateCamera(CameraUpdate.newLatLng(geolocation.coordinates));
                  controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation.bounds, 0));
                },
              ),
            ),
          ],
        )
      )
    );
  }
}
