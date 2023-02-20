import 'package:flutter/material.dart';
import 'package:gocar_apps/assistants/request_assistant.dart';
import 'package:gocar_apps/components/progress_dialog.dart';
import 'package:gocar_apps/global/global.dart';
import 'package:gocar_apps/global/map_key.dart';
import 'package:gocar_apps/handler/app_info.dart';
import 'package:gocar_apps/models/predicted.dart';
import 'package:provider/provider.dart';

import '../models/directions.dart';

class PlacePredictionTile extends StatefulWidget {

  final Predicted? predictedPlaces;

  PlacePredictionTile({
    this.predictedPlaces
  });

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(
        context: context,
        builder: (BuildContext ctx) => ProgressDialog(
          msg: "Sedang Diproses, Harap Tunggu...",
        ),
    );

    String placeDirectionDetails = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetails);

    Navigator.pop(context);

    if(responseApi == "Error Occured, Failed. No Response"){
      return;
    }

    if(responseApi["status"] == "OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLat = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLong = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddr(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });

      Navigator.pop(context, "obtainedDropOffLocation");
    }

  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: (){
          getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black54
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: Colors.grey,
              ),
              const SizedBox(width: 14,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8,),
                      Text(
                        widget.predictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 2.0,),
                      Text(
                        widget.predictedPlaces!.secondary_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }
}
