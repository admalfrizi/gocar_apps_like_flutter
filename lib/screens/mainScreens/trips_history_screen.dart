import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gocar_apps/components/history_design.dart';
import 'package:provider/provider.dart';

import '../../handler/app_info.dart';

class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Riwayat Perjalanan Anda"
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close,
          ),
          onPressed: () {
            SystemNavigator.pop();
          },
        ),
      ),
      body: ListView.separated(
        separatorBuilder: (context, i) =>
        const Divider(
          color: Colors.grey,
          thickness: 2,
          height: 2,
        ),
          itemBuilder: (context, i){
            return Card(
              color: Colors.white54,
              child: HistoryDesign(
                tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
              ),
            );
          },
          itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
      ),
    );
  }
}
