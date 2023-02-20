import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gocar_apps/assistants/assistant_methods.dart';
import 'package:gocar_apps/assistants/geofire_assistants.dart';
import 'package:gocar_apps/components/drawer_nav.dart';
import 'package:gocar_apps/components/pay_fare_amount_dialog.dart';
import 'package:gocar_apps/components/progress_dialog.dart';
import 'package:gocar_apps/global/global.dart';
import 'package:gocar_apps/handler/app_info.dart';
import 'package:gocar_apps/models/active_nearby_available_drivers.dart';
import 'package:gocar_apps/screens/mainScreens/rate_driver_screen.dart';
import 'package:gocar_apps/screens/mainScreens/search_places_screen.dart';
import 'package:gocar_apps/screens/mainScreens/select_nearest_active_driver_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignFromDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> coordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "";
  String userEmail = "";

  bool openDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearbyAvailableDriverList = [];

  DatabaseReference? refRideRequest;
  String driverRideStatus = "Supir Sedang Menuju Ke Lokasimu...";
  StreamSubscription<DatabaseEvent>? tripRideRequestInfoStreamSubscription;

  String userRideRequestStatus = "";
  bool requestPositionDetailsInfo = true;

  blackThemeGoogleMap(){
    newGoogleMapController?.setMapStyle(
        """
                        [
                            {
                                "featureType": "all",
                                "elementType": "all",
                                "stylers": [
                                    {
                                        "invert_lightness": true
                                    },
                                    {
                                        "saturation": 10
                                    },
                                    {
                                        "lightness": 30
                                    },
                                    {
                                        "gamma": 0.5
                                    },
                                    {
                                        "hue": "#435158"
                                    }
                                ]
                            }
                        ]
                    """
    );
  }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if(_locationPermission == LocationPermission.denied){
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  locatedUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition,zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    if (kDebugMode) {
      print("this is your address = $humanReadableAddress");
    }

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();

    AssistantMethods.readTripsKeysForOnlineUser(context);
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationPermissionAllowed() ;
  }

  saveRideRequestInformation() {

    refRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      "latitude" : originLocation!.locationLat.toString(),
      "longitude": originLocation.locationLong.toString(),
    };

    Map destinationLocationMap = {
      "latitude" : destinationLocation!.locationLat.toString(),
      "longitude": destinationLocation.locationLong.toString(),
    };

    Map userInfoMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    refRideRequest!.set(userInfoMap);
    tripRideRequestInfoStreamSubscription = refRideRequest!.onValue.listen((event) async {
      if(event.snapshot.value == null) {
        return;
      }

      if((event.snapshot.value as Map)["car_details"] != null){
        setState(() {
          driverCarDetails = (event.snapshot.value as Map)["car_details"].toString();
        });
      }

      if((event.snapshot.value as Map)["driverPhone"] != null){
        setState(() {
          driverPhone = (event.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if((event.snapshot.value as Map)["driverName"] != null){
        setState(() {
          driverName = (event.snapshot.value as Map)["driverName"].toString();
        });
      }

      if((event.snapshot.value as Map)["status"] != null){
        userRideRequestStatus = (event.snapshot.value as Map)["status"].toString();
      }

      if((event.snapshot.value as Map)["driverLocation"] != null){
        double driverCurrentPositionLat = double.parse((event.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLong = double.parse((event.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLong);

        if(userRideRequestStatus == "accepted"){
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }

        if(userRideRequestStatus == "arrived"){
          setState(() {
            driverRideStatus = "Kendaraan Anda Telah Tiba Di Lokasimu";
          });
        }

        if(userRideRequestStatus == "onTrip"){
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }
        if(userRideRequestStatus == "ended"){
          if((event.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((event.snapshot.value as Map)["fareAmount"].toString());
            var response = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext c) => PayFareAmountDialog(
                  totalFareAmount: fareAmount,
                )
            );

            if(response == "cashPaided"){
              if((event.snapshot.value as Map)["driverId"] != null){
                String assignedDriverId = (event.snapshot.value as Map)["driverId"].toString();

                Navigator.push(context, MaterialPageRoute(builder: (c)=> RateDriverScreen(
                  assignedDriverId: assignedDriverId
                )));

                refRideRequest!.onDisconnect();
                tripRideRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }
    });

    onlineNearbyAvailableDriverList = GeoFireAssistants.activeNearbyAvailableDriverList;
   searchNearestOnlineDrivers();
  }

  updateArrivalTimeToUserPickUpLocation(LatLng driverCurrentPositionLatLng) async {
    if(requestPositionDetailsInfo == true){
      requestPositionDetailsInfo = false;

      LatLng userPickUpLocation = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userPickUpLocation
      );

      if(directionDetailsInfo == null){

        return;

      } else {
        setState(() {

          driverRideStatus = "Supir Sedang Menuju Ke Lokasimu " + directionDetailsInfo.duration_text.toString();

        });

        requestPositionDetailsInfo = true;
      }
    }
  }

  updateReachingTimeToUserDropOffLocation(LatLng driverCurrentPositionLatLng) async {
    if(requestPositionDetailsInfo == true){
      requestPositionDetailsInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(dropOffLocation!.locationLat!, dropOffLocation.locationLong!);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng,
          userDestinationPosition
      );

      if(directionDetailsInfo == null){

        return;

      } else {
        setState(() {

          driverRideStatus = "Menuju Ke Tujuan Lokasi Anda : " + directionDetailsInfo.duration_text.toString();

        });

        requestPositionDetailsInfo = true;
      }
    }
  }


  searchNearestOnlineDrivers() async {
    if(onlineNearbyAvailableDriverList.isEmpty){

      refRideRequest!.remove();

      setState(() {
        polyLineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        coordinatesList.clear();
      });

      Fluttertoast.showToast(msg: "Buka Kembali Aplikasi Setiap Waktu, Aplikasi sedang memuat ulang...");

      Future.delayed(const Duration(milliseconds: 4000), (){
        SystemNavigator.pop();
      });

      return;
    }

    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriverList);
    
    var response =  await Navigator.push(context, MaterialPageRoute(builder: (c) => SelectNearestActiveDriverScreen(refRideRequest: refRideRequest)));

    if(response == "Kendaraan Telah Anda Pilih !"){
      FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).once().then((snap) {
        if(snap.snapshot.value != null){

          sendNotificationToDriverNow(chosenDriverId!);

          showWaitingResponseUI();

          FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId!).child("newRideStatus")
              .onValue.listen((eventSnapshot) {
                if(eventSnapshot.snapshot.value == "idle"){

                  Fluttertoast.showToast(msg: "Mohon maaf supir membatalkan permintaan anda, Silahkan Cari Yang Lain");

                  Future.delayed(const Duration(milliseconds: 3000),(){
                    Fluttertoast.showToast(msg: "Buka Kembali Aplikasi Anda");
                    SystemNavigator.pop();
                  });
                }

                if(eventSnapshot.snapshot.value == "accepted"){
                  showUIForAssignedDriverInfo();
                }
          });

        } else {
          Fluttertoast.showToast(msg: "Maaf Supir anda sedang tidak ada di tempat !");
        }
      });
    }
  }
  showUIForAssignedDriverInfo(){

    setState(() {
      waitingResponseFromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignFromDriverContainerHeight = 245;
    });
  }

  showWaitingResponseUI() {
    setState(() {
      searchLocationContainerHeight = 0;
      waitingResponseFromDriverContainerHeight = 220;
    });
  }

  sendNotificationToDriverNow(String chosenDriverId) {
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("newRideStatus").set(refRideRequest!.key);
    FirebaseDatabase.instance.ref().child("drivers").child(chosenDriverId).child("token").once().then((snap){
      if(snap.snapshot.value != null){

        String deviceRegisteredtoken = snap.snapshot.value.toString();
        
        AssistantMethods.sendNotificationToDriverNow(deviceRegisteredtoken, refRideRequest!.key.toString(), context);

        Fluttertoast.showToast(msg: "Permintaan Anda Telah Dikirim.");

      } else {
        Fluttertoast.showToast(msg: "Pilih Supir yang tersedia.");
        return;
      }
    });
  }


  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for(int i=0; i<onlineNearestDriversList.length; i++){
      await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot){
        var driverKeyInfo = dataSnapshot.snapshot.value;
        dList.add(driverKeyInfo);
        if (kDebugMode) {
          print("driver key information = $dList");
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    createActiveNearByDriverIconMarker();
    return SafeArea(
      child: Scaffold(
        key: sKey,
        drawer: Container(
          width: 265,
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: Colors.black
            ),
            child: MyDrawer(
              name: userName,
              email: userEmail,
            ),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
                padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: true,
                initialCameraPosition: _kGooglePlex,
                polylines: polyLineSet,
                markers: markersSet,
                circles: circlesSet,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  newGoogleMapController = controller;
                  blackThemeGoogleMap();

                  setState(() {
                    bottomPaddingOfMap = 225;
                  });
                  locatedUserPosition();
                },
            ),

            Positioned(
                top: 10,
                left: 18,
                child: GestureDetector(
                  onTap: () {
                    if(openDrawer){
                      sKey.currentState!.openDrawer();
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(
                      openDrawer ? Icons.menu : Icons.close,
                      color: Colors.black54
                    ),
                  ),
                )
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                curve: Curves.easeIn,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  height: searchLocationContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                            const SizedBox(width: 12,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Dari",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12
                                  ),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context).userPickupLocation != null
                                      ? "${(Provider.of<AppInfo>(context).userPickupLocation!.locationName!).substring(0,30)}..."
                                      : "Tidak Ada Posisi",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10,),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16,),
                        GestureDetector(
                          onTap: () async {
                            var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> const SearchPlacesScreen()));

                            if(responseFromSearchScreen == "obtainedDropOffLocation"){
                              setState(() {
                                openDrawer = false;
                              });
                              await drawPolyLineFromOriginToDestination();
                            }
                            },
                          child: Row(
                            children: [
                              const Icon(Icons.add_location_alt_outlined, color: Colors.grey,),
                              const SizedBox(width: 12,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Menuju Ke",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12
                                    ),
                                  ),
                                  Text(
                                    Provider.of<AppInfo>(context).userDropOffLocation != null
                                      ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                      : "Ga ada tempatnya!",
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16,),

                        ElevatedButton(
                            onPressed: () {
                              if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null){
                                saveRideRequestInformation();
                              } else {
                                Fluttertoast.showToast(msg: "Tolong masukan tujuan anda yang valid !");
                              }
                            },
                            child: Text(
                              "Carikan Supir",
                            ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: waitingResponseFromDriverContainerHeight,
                decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        FadeAnimatedText(
                          'Menunggu Konfirmasi dari Supir Kendaraan...',
                          duration: const Duration(seconds: 6),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(fontSize: 50.0,color: Colors.white ,fontWeight: FontWeight.bold),
                        ),
                        ScaleAnimatedText(
                          'Harap Menunggu...',
                          duration: const Duration(seconds: 10),
                          textAlign: TextAlign.center,
                          textStyle: const TextStyle(fontSize: 32.0,color: Colors.white , fontFamily: 'Canterbury'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: assignFromDriverContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)
                    )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            driverRideStatus,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54
                            )
                          ),
                        ),
                        const SizedBox(
                          height: 20.0
                        ),
                        const Divider(
                          height: 2,
                          thickness: 2,
                          color: Colors.white54
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Text(
                            driverCarDetails,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white54
                            )
                        ),
                        const SizedBox(
                            height: 2.0
                        ),
                        Text(
                            driverName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54
                            )
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        const Divider(
                            height: 2,
                            thickness: 2,
                            color: Colors.white54
                        ),
                        const SizedBox(
                            height: 20.0
                        ),
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: (){

                            },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green
                              ),
                            icon: const Icon(
                              Icons.phone_android,
                              color: Colors.black54,
                              size: 22,
                            ),
                            label: Text(
                              "Call Driver",
                              style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold
                              )
                            )
                          ),
                        ),
                      ],
                    ),
                  )
                )
              ),
          ],
        )
      ),
    );
  }

  Future<void> drawPolyLineFromOriginToDestination() async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickupLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLat!, originPosition.locationLong!);
    var destinationLatLng = LatLng(destinationPosition!.locationLat!, destinationPosition.locationLong!);

    showDialog(context: context,
        builder: (BuildContext context)=> ProgressDialog(
          msg: "Mohon Tunggu...",
        ));

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = directionDetailsInfo;
    });

    Navigator.pop(context);

    print("There are points");
    print(directionDetailsInfo?.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo!.e_points!);

    coordinatesList.clear();

    if(decodedPolyLinePointsResultList.isNotEmpty)
    {
      decodedPolyLinePointsResultList.forEach((PointLatLng pointLatLng)
      {
        coordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: Colors.purpleAccent,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: coordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

  }

  initializeGeoFireListener(){
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!.listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLat = map['latitude'];
            activeNearbyAvailableDriver.locationLong = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];

            GeoFireAssistants.activeNearbyAvailableDriverList.add(activeNearbyAvailableDriver);

            if(activeNearbyDriverKeysLoaded == true){
              displayActiveDriversOnUsersMap();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistants.deleteDriverFromList(map['key']);
            break;

          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLat = map['latitude'];
            activeNearbyAvailableDriver.locationLong = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];

            GeoFireAssistants.updateactiveNearbyAvailableDriversLocation(activeNearbyAvailableDriver);
            displayActiveDriversOnUsersMap();
            break;

          case Geofire.onGeoQueryReady:
            displayActiveDriversOnUsersMap();
            break;
        }
      }
      setState(() {

      });
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driverMarkerSet = <Marker>{};

      for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistants.activeNearbyAvailableDriverList) {
        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLat!, eachDriver.locationLong!);

        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          rotation: 360
        );

        driverMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driverMarkerSet;
      });
    });
  }

  createActiveNearByDriverIconMarker()
  {
    if(activeNearbyIcon == null)
    {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "assets/car.png").then((value)
      {
        activeNearbyIcon = value;
      });
    }
  }


}
