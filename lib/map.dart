import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:demo/feedback.dart';
import 'package:location/location.dart';

class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key}) : super(key: key);

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  late GoogleMapController googleMapController;
  List users = [];

  static const CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markerpoint = {};
  Set<Marker> mark = {};
  var markerID = 0;

  //direction line
  PolylinePoints polylinePoints = PolylinePoints();

  String googleAPiKey = "AIzaSyDf5GmOWGjc3gBqOAqhVjH5VhU2CZPa-eI";
  //String googleAPiKey = "AIzaSyDHjLpt5b8jDElJPcDn8q02COHwLHwgPzE";

  //polylines to show direction
  Map<PolylineId, Polyline> polylines = {};

  double distance = 0.0;

  var locationCurrent = Location();
  late LocationData currentLocation;

  @override
  void initState() {
    super.initState();
    firstApprun();
  }

  firstApprun() async {
    await location();
    locationCurrent = new Location();
    locationCurrent.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
    print("bbbbb");
    print(currentLocation.latitude);
    print(currentLocation.longitude);
  }

  location() async {
    Position position = await _determinePosition();

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18)));
    markerpoint.clear();
    markerpoint.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: LatLng(position.latitude, position.longitude)));

    await getlightdata();
    for (var i = 0; i < users.length; i++) {
      bool working = users[i]["isWorking"];
      if (working == false) {
        double lat = users[i]["latitude"];
        double long = users[i]["longitude"];
        markerID += 1;
        final Uint8List markerIcon =
            await getBytesFromAsset('image/light.png', 50);
        markerpoint.add(Marker(
          markerId: MarkerId(markerID.toString()),
          position: LatLng(lat, long),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Expanded(
                  child: AlertDialog(
                    backgroundColor: Color.fromRGBO(61, 62, 63, 1),
                    title: Text('Are You Sure?',style: TextStyle(color: Colors.white),),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CurrentLocationScreen()));
                        },
                        child: Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => feedbackform(
                                    streetlight_id: users[i]["id"],
                                    Village: users[i]["village"],
                                    Pincode: users[i]["pincode"],
                                    Taluka: users[i]["tehsil"],
                                    District: users[i]["district"])),
                          );
                        },
                        child: Text('ACCEPT'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ));
        await getDirections(lat, long);
      }
    }
    setState(() {});
  }

  Future getlightdata() async {
    var response = await get(Uri.parse(
        'https://heroku-backend-hackathone.herokuapp.com/api/position/positions'));

    var data = jsonDecode(response.body);
    var data1 = data["data"];
    print(data1);
    for (var u in data1) {
      User user = User(
          Isworking: u["is_working"],
          lat: u["latitude"],
          long: u["longitude"],
          village: u["village"],
          id: u["id"],
          district: u["district"],
          pincode: u["pincode"],
          tehsil: u["tehsil"]);
      users.add({
        "isWorking": user.Isworking,
        "latitude": user.lat,
        "longitude": user.long,
        "village": user.village,
        "id": user.id,
        "district": user.district,
        "pincode": user.pincode,
        "tehsil": user.tehsil
      });
    }
    print(users);
  }

  getDirections(double a, double b) async {
    List<LatLng> polylineCoordinates = [];

    Position position = await _determinePosition();

    LatLng startLocation = LatLng(position.latitude, position.longitude);
    LatLng endLocation = LatLng(a, b);

    print(
        "position.latitude ===> ${position.latitude}  &&&&& position.longitude ===> ${position.longitude}");
    print("a ===> $a &&&&& b ===> $b");

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for (var i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i + 1].latitude,
          polylineCoordinates[i + 1].longitude);
    }

    print(totalDistance);

    setState(() {
      distance = totalDistance;
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      visible: true,
      polylineId: id,
      color: const Color.fromRGBO(61, 62, 63, 1),
      points: polylineCoordinates,
      width: 6,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Location location = Location();
    // late LocationData _locationData;

    //serviceEnabled = await location.isBackgroundModeEnabled();
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Future<Position> position = Geolocator.getCurrentPosition();
    //_locationData = await location.getLocation();

    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: distance == 0.0
          ? AppBar(
              title: const Text("User current location"),
              backgroundColor: const Color.fromRGBO(61, 62, 63, 1),
              centerTitle: true,
            )
          : AppBar(
              title: Text("Total Distance: ${distance.toStringAsFixed(2)} KM"),
              backgroundColor: const Color.fromRGBO(61, 62, 63, 1),
              centerTitle: true,
            ),
      body: Stack(children: [
        GoogleMap(
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          initialCameraPosition: initialCameraPosition,
          mapType: MapType.normal,
          polylines: Set<Polyline>.of(polylines.values),
          markers: Set<Marker>.of(markerpoint),
          onMapCreated: (mapController) {
            googleMapController=mapController;
          },
        ),
        // Positioned(
        //     bottom: 200,
        //     left: 50,
        //     child: Container(
        //         child: Card(
        //       child: Container(
        //           padding: EdgeInsets.all(20),
        //           child: Text(
        //               "Total Distance: ${distance.toStringAsFixed(2)} KM",
        //               style: const TextStyle(
        //                   fontSize: 20, fontWeight: FontWeight.bold))),
        //     )))
      ]),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     await location();
      //   },
      //   label: const Text("Current Location"),
      //   icon: const Icon(Icons.location_history),
      // ),
    );
  }
}

class User {
  final bool Isworking;
  final double lat, long;
  final int pincode;
  final String village, id, district, tehsil;

  User(
      {required this.Isworking,
      required this.lat,
      required this.long,
      required this.village,
      required this.id,
      required this.district,
      required this.pincode,
      required this.tehsil});
}
