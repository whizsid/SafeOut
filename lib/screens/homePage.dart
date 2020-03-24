

import 'package:flutter/material.dart';
import 'package:safeout/screens/mapPage.dart';
import 'package:safeout/services/http.dart';
import 'package:safeout/services/location.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final LocationService locationService = LocationService();
  final HttpService httpService = HttpService();
  bool userLocationLoaded = false;

  void initState(){
    super.initState();

    this.httpService.getToken();

    this.locationService.listen((latLng){
      if(!this.userLocationLoaded){
        
        this.userLocationLoaded = true;

        Navigator.push(context, MaterialPageRoute(builder: (context)=> MapPage(
          key: this.widget.key,
          title: this.widget.title,
          httpService: this.httpService,
          locationService: this.locationService
        )));
      } else {
        this.httpService.saveLocation(latLng);
      }
    });

    this.locationService.enableLocationService();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
          // Center the content
          child: Center(
            // Add Text
            child: Text(widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 38.0
                )
            ),
          ),
          color: Colors.deepPurple,
      ),
    );
  }
}
