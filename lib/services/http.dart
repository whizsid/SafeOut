import "dart:async";
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse {
  bool status;
  Map<String,dynamic> data;
  String message;

  ApiResponse({
    @required this.status,
    @required this.data,
    @required this.message
  });

  factory ApiResponse.fromResponse(Response response){

    if(response.statusCode >= 200 && response.statusCode <= 210){
      // print("Server Response:- " + response.body);

      Map<String,dynamic> json = jsonDecode(response.body);

      String status = json["status"] as String;

      if(json['data'] is List){

      }

      return ApiResponse (
        status: status =="success",
        data: (json['data'] is List)? {} : (json["data"] as Map<String,dynamic>),
        message: json["message"] as String
      );
    } else {
      // print("Server Error!");
      return ApiResponse(status: false, data:{}, message: "Network Error");
    }
  }
}

class HttpService {
  final String apiUrl = FlutterConfig.get("API_URL");
  String userToken;
  String uniqueId;


  Future<String> getToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String token = prefs.getString("userToken");
    String uniqueId = prefs.getString("uniqueId");

    if(token!=null&& uniqueId!=null){
      this.userToken = token;
      this.uniqueId = uniqueId;
      return token;
    }

    Response res = await get(apiUrl+"get-token");
    ApiResponse apiResponse = ApiResponse.fromResponse(res);

    if(!apiResponse.status){
      return null;
    }

    this.userToken = apiResponse.data['token'] as String;
    this.uniqueId = apiResponse.data['unique_id'];

    await prefs.setString("userToken", this.userToken);
    await prefs.setString("uniqueId", this.uniqueId);

    return this.userToken;
  }

  Future<List<LatLng>> getUserLocations(LatLng latLng) async {

    if(this.userToken==null || this.uniqueId==null){
      return List();
    }

    Response res = await post(apiUrl+"show-user-locations", 
      body: {
        "Lat": latLng.latitude.toString(),
        "Lng": latLng.longitude.toString(),
        "Token": this.userToken
      }
    );

    ApiResponse apiResponse = ApiResponse.fromResponse(res);

    if(!apiResponse.status){
      return List();
    }

    List<dynamic> usersList = apiResponse.data['users'];
    List<LatLng> coordList = List();

    usersList.forEach((latLng){
      coordList.add(LatLng( double.parse(latLng["lat"]), double.parse( latLng["lng"])));
    });

    return coordList;
  }

  Future<bool> saveLocation(LatLng latLng) async {

    if(this.userToken == null || this.uniqueId == null){
      return false;
    }

    Response res = await post( apiUrl+"save-user-location",
      body: {
        "Lat": latLng.latitude.toString(),
        "Lng": latLng.longitude.toString(),
        "unique_id": this.uniqueId,
        "Token": this.userToken
      }
    );

    ApiResponse apiResponse = ApiResponse.fromResponse(res);

    return apiResponse.status;
  }
}