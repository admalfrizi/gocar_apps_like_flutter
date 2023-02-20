import 'package:flutter/cupertino.dart';
import 'package:gocar_apps/models/trips_history_model.dart';

import '../models/directions.dart';

class AppInfo extends ChangeNotifier{
  Directions? userPickupLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickupLocationAddr(Directions userPickUpAddr) {
    userPickupLocation = userPickUpAddr;
    notifyListeners();
  }

  void updateDropOffLocationAddr(Directions userDropOffAddr) {
    userDropOffLocation = userDropOffAddr;
    notifyListeners();
  }

  void updateOverAllTripsCounter(int overAllTripsCounter){
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  void updateOverAllTripsKeys(List<String> tripKeysList){
    historyTripKeysList = tripKeysList;
    notifyListeners();
  }

  void updateOverAllTripsHistoryInfo(TripsHistoryModel historyTrips){
    allTripsHistoryInformationList.add(historyTrips);
    notifyListeners();
  }
}