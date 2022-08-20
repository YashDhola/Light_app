// import 'dart:convert';
// import 'dart:math';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import 'package:demo/feedback.dart';
//
// Map<PolylineId, Polyline> polylines = {};
// PolylinePoints polylinePoints = PolylinePoints();
// String googleAPiKey = "AIzaSyDf5GmOWGjc3gBqOAqhVjH5VhU2CZPa-eI";
// List users = [];
// double distance = 0.0;
//
// Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission;
//
//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//
//   if (!serviceEnabled) {
//     return Future.error('Location services are disabled');
//   }
//
//   permission = await Geolocator.checkPermission();
//
//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//
//     if (permission == LocationPermission.denied) {
//       return Future.error("Location permission denied");
//     }
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     return Future.error('Location permissions are permanently denied');
//   }
//
//   Position position = await Geolocator.getCurrentPosition();
//
//   return position;
// }
//
// Future<Uint8List> getBytesFromAsset(String path, int width) async {
//   ByteData data = await rootBundle.load(path);
//   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//       targetWidth: width);
//   ui.FrameInfo fi = await codec.getNextFrame();
//   return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//       .buffer
//       .asUint8List();
// }
//
// Future getlightdata() async {
//   var response = await get(Uri.parse(
//       'https://heroku-backend-hackathone.herokuapp.com/api/position/positions'));
//
//   var data = jsonDecode(response.body);
//   var data1 = data["data"];
//   print(data1);
//   for (var u in data1) {
//     User user = User(
//         Isworking: u["is_working"],
//         lat: u["latitude"],
//         long: u["longitude"],
//         village: u["village"],
//         id: u["id"],
//         district: u["district"],
//         pincode: u["pincode"],
//         taluka: u["taluka"]);
//     users.add({
//       "isWorking": user.Isworking,
//       "latitude": user.lat,
//       "longitude": user.long,
//       "village": user.village,
//       "id": user.id,
//       "district": user.district,
//       "pincode": user.pincode,
//       "taluka": user.taluka
//     });
//   }
//   print(users);
// }
//
// class User {
//   final bool Isworking;
//   final double lat, long;
//   final int pincode;
//   final String village, id, district, taluka;
//
//   User(
//       {required this.Isworking,
//         required this.lat,
//         required this.long,
//         required this.village,
//         required this.id,
//         required this.district,
//         required this.pincode,
//         required this.taluka});
// }
//
// getDirections(double a, double b) async {
//   List<LatLng> polylineCoordinates = [];
//
//   Position position = await _determinePosition();
//
//   LatLng startLocation = LatLng(position.latitude, position.longitude);
//   LatLng endLocation = LatLng(a, b);
//
//   print(
//       "position.latitude ===> ${position.latitude}  &&&&& position.longitude ===> ${position.longitude}");
//   print("a ===> $a &&&&& b ===> $b");
//
//   try {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//       googleAPiKey,
//       PointLatLng(startLocation.latitude, startLocation.longitude),
//       PointLatLng(endLocation.latitude, endLocation.longitude),
//       travelMode: TravelMode.driving,
//     );
//     print("result ===> ${result.points}");
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     } else {
//       print(result.errorMessage);
//     }
//     print("result ===> ${result.points}");
//     //polulineCoordinates is the List of longitute and latidtude.
//     double totalDistance = 0;
//     for (var i = 0; i < polylineCoordinates.length - 1; i++) {
//       print("000000");
//       print(polylineCoordinates[i].latitude);
//       print(polylineCoordinates[i].longitude);
//       print(polylineCoordinates[i + 1].latitude);
//       print(polylineCoordinates[i + 1].longitude);
//       totalDistance += calculateDistance(
//           polylineCoordinates[i].latitude,
//           polylineCoordinates[i].longitude,
//           polylineCoordinates[i + 1].latitude,
//           polylineCoordinates[i + 1].longitude);
//     }
//     print(totalDistance);
//     distance = totalDistance;
//
//     //add to the list of poly line coordinates
//     addPolyLine(polylineCoordinates);
//   } on Exception catch (e) {
//     print("error polyline====>" + e.toString());
//   }
// }
//
// addPolyLine(List<LatLng> polylineCoordinates) {
//   PolylineId id = PolylineId("poly");
//   Polyline polyline = Polyline(
//     visible: true,
//     polylineId: id,
//     color: Colors.deepPurpleAccent,
//     points: polylineCoordinates,
//     width: 8,
//   );
//   polylines[id] = polyline;
// }
//
// double calculateDistance(lat1, lon1, lat2, lon2) {
//   var p = 0.017453292519943295;
//   var a = 0.5 -
//       cos((lat2 - lat1) * p) / 2 +
//       cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
//   return 12742 * asin(sqrt(a));
// }
//
// class CurrentLocationScreen extends StatefulWidget {
//   const CurrentLocationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
// }
//
// class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
//
//   @override
//   void initState() async {
//     // TODO: implement initState
//     super.initState();
//     Position position = await _determinePosition();
//     const CameraPosition initialCameraPosition = CameraPosition(
//         target: LatLng(position.latitude, position.longitude), zoom: 14);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
