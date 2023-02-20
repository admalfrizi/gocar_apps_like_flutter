import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gocar_apps/assistants/assistant_methods.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../../global/global.dart';

class SelectNearestActiveDriverScreen extends StatefulWidget {

  DatabaseReference? refRideRequest;

  SelectNearestActiveDriverScreen({super.key, this.refRideRequest});

  @override
  State<SelectNearestActiveDriverScreen> createState() => _SelectNearestActiveDriverScreenState();
}

class _SelectNearestActiveDriverScreenState extends State<SelectNearestActiveDriverScreen> {

  String fareAmount = "";

  getFareAmountByTypeCar(int index){
    if(tripDirectionDetails != null){
      if(dList[index]["car_details"]["type"].toString() == "Ojek"){
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!) / 2).toString();
    } else if(dList[index]["car_details"]["type"].toString() == "Standar"){
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!)).toString();
      } else if(dList[index]["car_details"]["type"].toString() == "X-tra Besar"){
        fareAmount = (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetails!) * 2).toString();
      }
    }

    return fareAmount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.white54,
          title: const Text(
            "Nearest Online Drivers",
            style: TextStyle(
              fontSize: 18
            ),
          ),
          leading: IconButton(
            onPressed: (){
              widget.refRideRequest!.remove();
              Fluttertoast.showToast(msg: "Permintaan Driver Di Batalkan !");
              SystemNavigator.pop();
            },
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView.builder(
          itemBuilder: (BuildContext ctx, int index){
            return GestureDetector(
              onTap: (){
                setState(() {
                  chosenDriverId = dList[index]["id"].toString();
                });
                Navigator.pop(context, "Kendaraan Telah Anda Pilih !");
              },
              child: Card(
                elevation: 3,
                shadowColor: Colors.green,
                margin: EdgeInsets.all(8),
                color: Colors.grey,
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Image.asset(
                      "assets/${dList[index]["car_details"]["type"]}.png",
                      width: 70,
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dList[index]["name"],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54
                        ),
                      ),
                      Text(
                        dList[index]["car_details"]["car_model"],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white54
                        ),
                      ),
                      SmoothStarRating(
                        rating: dList[index]["ratings"] == null ? 0.0 : double.parse(dList[index]["ratings"]),
                        color: Colors.black,
                        borderColor: Colors.black,
                        allowHalfRating: true,
                        starCount: 5,
                        size: 15,
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rp. " + getFareAmountByTypeCar(index),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        tripDirectionDetails != null ? tripDirectionDetails!.duration_text! : "",
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 2,),
                      Text(
                        tripDirectionDetails != null ? tripDirectionDetails!.distance_text! : "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black54
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: dList.length,
        ),
      ),
    );
  }
}
