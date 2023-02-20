import 'package:flutter/material.dart';
import 'package:gocar_apps/assistants/request_assistant.dart';
import 'package:gocar_apps/components/place_prediction_tile.dart';
import 'package:gocar_apps/global/map_key.dart';
import 'package:gocar_apps/models/predicted.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<Predicted> placeSuggestionList = [];

  void findPlaceAutoCompleteSearch(String inputTxt) async {
    if(inputTxt.length > 1) {
      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputTxt&key=$mapKey&components=country:ID";

      var responseAutoComplete = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoComplete == "Error Occured, Failed. No Response"){
        return;
      }

      var placeSuggestions = responseAutoComplete["predictions"];

      var placePredictionsList = (placeSuggestions as List).map((jsonData) => Predicted.fromJson(jsonData)).toList();

      setState(() {
        placeSuggestionList = placePredictionsList;
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Colors.black54,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7
                    ),
                  ),
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                              Icons.arrow_back,
                              color: Colors.grey,
                          ),
                        ),
                        Center(
                          child: Text(
                            "Cari Lokasi Tujuan Anda",
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0,),
                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_sharp,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 18.0,),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              onChanged: (value) {
                                findPlaceAutoCompleteSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: "Cari Disini...",
                                fillColor: Colors.white54,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  left: 11,
                                  top: 8,
                                  bottom: 8
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ]
                ),
              ),
            ),
            (placeSuggestionList.length > 0)
            ? Expanded(
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  return PlacePredictionTile(
                    predictedPlaces: placeSuggestionList[index],
                  );
                },
                separatorBuilder: (BuildContext ctx, int index) {
                  return const Divider(
                    height: 1,
                    color: Colors.grey,
                    thickness: 1,
                  );
                },
                itemCount: placeSuggestionList.length
              ),
            )
            : Container(),
          ],
        ),
      ),
    );
  }
}
