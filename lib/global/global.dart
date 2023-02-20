import 'package:firebase_auth/firebase_auth.dart';
import '../models/direction_details.dart';

import '../models/user.dart';


final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModel? userModelCurrentInfo;
List dList = [];
DirectionDetails? tripDirectionDetails;
String? chosenDriverId = "";
String serverTokenFcm = "key=AAAAD5bBpdY:APA91bE7wUE5kRjEYV_DEDxkPPSwgZbKUKP3I9k9dUz4XIOfRHbeJtQv4vjtbMbY7hVJ8umNugH0utfmkEB9s7G-asqsQnpCykPGKLwaB14jJ6vUKNEBS7PHyBPiimzq6L95MBdBnmqC";
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
String driverPhone = "";
double countRatingStars = 0.0;
String titleRating = "";