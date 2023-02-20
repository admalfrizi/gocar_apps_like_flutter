import '../models/active_nearby_available_drivers.dart';

class GeoFireAssistants {

  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriverList = [];

  static void deleteDriverFromList(String driverId){
    int indexNumber = activeNearbyAvailableDriverList.indexWhere((element) => element.driverId == driverId);

    activeNearbyAvailableDriverList.removeAt(indexNumber);
  }

  static void updateactiveNearbyAvailableDriversLocation(ActiveNearbyAvailableDrivers driverWhoMove){
    int indexNumber = activeNearbyAvailableDriverList.indexWhere((element) => element.driverId == driverWhoMove.driverId);

    activeNearbyAvailableDriverList[indexNumber].locationLat = driverWhoMove.locationLat;
    activeNearbyAvailableDriverList[indexNumber].locationLong = driverWhoMove.locationLong;
  }

}