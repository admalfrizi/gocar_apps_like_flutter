import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

import '../../global/global.dart';

class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;

  RateDriverScreen({
    this.assignedDriverId
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        backgroundColor: Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 22,
              ),
              const Text(
                "Berikan Rating pada Supir",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(
                height: 22.0,
              ),
              const Divider(
                height: 4.0,
                thickness: 4.0,
              ),
              const SizedBox(
                height: 22.0,
              ),
              SmoothStarRating(
                rating: countRatingStars,
                allowHalfRating: false,
                starCount: 5,
                size: 46,
                color: Colors.green,
                borderColor: Colors.green,
                onRatingChanged: (valueOfStarsChoosed){
                  countRatingStars = valueOfStarsChoosed;

                  if(countRatingStars == 1){
                    setState(() {
                      titleRating = "Sangat Buruk";
                    });
                  }
                  if(countRatingStars == 2){
                    setState(() {
                      titleRating = "Buruk";
                    });
                  }
                  if(countRatingStars == 3){
                    setState(() {
                      titleRating = "Ok";
                    });
                  }
                  if(countRatingStars == 4){
                    setState(() {
                      titleRating = "Bagus";
                    });
                  }
                  if(countRatingStars == 5){
                    setState(() {
                      titleRating = "Sangat Bagus";
                    });
                  }
                },
              ),
              const SizedBox(
                height: 12.0,
              ),
              Text(
                titleRating,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              ElevatedButton(
                  onPressed: (){
                    DatabaseReference rateDriverRef = FirebaseDatabase.instance.ref()
                        .child("drivers").child(widget.assignedDriverId!).child("ratings");

                    rateDriverRef.once().then((snap){

                      if(snap.snapshot.value == null){
                        rateDriverRef.set(countRatingStars.toString());
                        
                        SystemNavigator.pop();
                      } else {
                        double pastRating = double.parse(snap.snapshot.value.toString());
                        double newAverageRatings = (pastRating + countRatingStars) / 2;

                        rateDriverRef.set(newAverageRatings);
                        SystemNavigator.pop();

                      }
                      Fluttertoast.showToast(msg: "Buka Kembali Aplikasinya");

                    });

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 74),
                  ),
                  child:const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
