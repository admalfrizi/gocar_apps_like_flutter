import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar_apps/assistants/request_assistant.dart';
import 'package:gocar_apps/global/global.dart';
import 'package:gocar_apps/global/map_key.dart';
import 'package:gocar_apps/handler/app_info.dart';
import 'package:gocar_apps/models/direction_details.dart';
import 'package:gocar_apps/models/directions.dart';
import 'package:gocar_apps/models/trips_history_model.dart';
import 'package:gocar_apps/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddr = "";

    var reqResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(reqResponse != "Error Occured, Failed. No Response"){
      humanReadableAddr = reqResponse["results"][0]["formatted_address"];

      Directions userPickUpAddr = Directions();
      userPickUpAddr.locationLat = position.latitude;
      userPickUpAddr.locationLong = position.longitude;
      userPickUpAddr.locationName = humanReadableAddr;

      Provider.of<AppInfo>(context, listen: false).updatePickupLocationAddr(userPickUpAddr);
    }

    return humanReadableAddr;
  }

  static void readCurrentOnlineUserInfo(){
    currentFirebaseUser = firebaseAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance.ref()
        .child("users").child(currentFirebaseUser!.uid);

    userRef.once().then((snap) {
      if(snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapShot(snap.snapshot);
        if (kDebugMode) {
          print("name = ${userModelCurrentInfo!.name}");
          print("email = ${userModelCurrentInfo!.email}");
        }
      }
    });
  }

  static Future<DirectionDetails?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async{
    String urlOriginToDestinationWays = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationWays);

    if(responseDirectionApi == "Error Ocurred, Failed, No Response"){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();
    directionDetails.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetails.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static double calculateFareAmountFromOriginToDestination(DirectionDetails directionDetails){
    double timeTraveledFareAmountPerMinute = (directionDetails.duration_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer = (directionDetails.duration_value! / 1000) * 0.1;

    double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    double localCurrencyTotalAmount = totalFareAmount * 14990;

    return double.parse(localCurrencyTotalAmount.toStringAsFixed(0));
  }

  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, BuildContext context) async {

    var destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      "Content-Type" : 'application/json',
      "Authorization": serverTokenFcm
    };

    Map bodyNotification = {
      "body": "Tujuan Alamat, \n$destinationAddress",
      "title": "Ada Penumpang yang mau naik !"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": 1,
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotifFormat = {
      "notification" : bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken
    };

    var responseNotification = http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(officialNotifFormat),
    );
  }

  static void readTripsKeysForOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests")
        .orderByChild("userName").equalTo(userModelCurrentInfo!.name)
        .once().then((snap){
          if(snap.snapshot.value != null){
            Map keysTripsId = snap.snapshot.value as Map;

            int overAllTripsCounter = keysTripsId.length;
            Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

            List<String> tripKeysList = [];
            keysTripsId.forEach((key, value) {
              tripKeysList.add(key);
            });

            Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripKeysList);
            
            readTripsHistoryInformation(context);
          }
    });
  }

  static void readTripsHistoryInformation(context) {
    var tripAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripKeysList;

    for(String eachKey in tripAllKeys){
      FirebaseDatabase.instance.ref().child("All Ride Requests").child(eachKey).once()
          .then((snap){
            var eachTripsHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

            if((snap.snapshot.value as Map)["status"] == "ended"){
              Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInfo(eachTripsHistory);
            }
      });
    }
  }
}