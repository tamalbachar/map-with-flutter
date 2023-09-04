// ignore_for_file: prefer_const_constructors
import 'dart:developer';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:location/location.dart';
import 'package:map_module/data_handler.dart';

void main() {
  final myWidget = MyWidget();
  myWidget.fetchATMData();
  myWidget.fetchBranchesData();
  runApp(MaterialApp(home: MyMap()));
}

mixin GetCoordinates {
  //get atm lat and long
  final List<GeoPoint> atmCoordinates = [];
  final List<GeoPoint> branchesCoordinates = [];
  Future<void> fetchATMData() async {
    final List<dynamic> atmData =
        await DataHandler().fetchATMDataFromMapModuleApp();
    for (var i = 0; i < atmData.length; i++) {
      var atmLat = double.parse(atmData.elementAt(i)['latitude']);
      var atmLong = double.parse(atmData.elementAt(i)['longitude']);
      atmCoordinates.add(GeoPoint(latitude: atmLat, longitude: atmLong));
    }
    //return atmCoordinates;
  }

  Future<List<GeoPoint>> fetchATMLatLng() async {
    await fetchATMData();
    return atmCoordinates;
  }
}

mixin GetBranchData {
  final List<GeoPoint> branchesCoordinates = [];
  Future<void> fetchBranchesData() async {
    final List<dynamic> branchesData =
        await DataHandler().fetchBranchDataFromMapModuleApp();
    for (var i = 0; i < branchesData.length; i++) {
      var branchLat = double.parse(branchesData.elementAt(i)['latitude']);
      var branchLong = double.parse(branchesData.elementAt(i)['longitude']);
      branchesCoordinates
          .add(GeoPoint(latitude: branchLat, longitude: branchLong));
    }
  }

  Future<List<GeoPoint>> fetchBranchLatLng() async {
    await fetchBranchesData();
    return branchesCoordinates;
  }
}

class MyMap extends StatefulWidget {
  MyMap({Key? key}) : super(key: key);
  @override
  MyWidget createState() => MyWidget();
}

class MyWidget extends State<MyMap> with GetCoordinates, GetBranchData {
  late MapController controller;
  List<StaticPositionGeoPoint> staticPoints = [];
  @override
  void initState() {
    super.initState();

    controller = MapController.withUserPosition(
        trackUserLocation: UserTrackingOption(
      enableTracking: true,
      unFollowUser: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Powered by Xerago', textDirection: TextDirection.ltr),
        //textDirection: TextDirection.ltr
      ),
      body: FutureBuilder<List<List<GeoPoint>>>(
        future: Future.wait([fetchATMLatLng(), fetchBranchLatLng()]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            staticPoints = [
              StaticPositionGeoPoint(
                'ATM',
                MarkerIcon(
                  icon: Icon(
                    Icons.currency_rupee_rounded,
                    color: Color.fromARGB(255, 196, 86, 26),
                    size: 48,
                  ),
                ),
                snapshot.data![0],
              ),
              StaticPositionGeoPoint(
                'Branches',
                MarkerIcon(
                  icon: Icon(
                    Icons.house_rounded,
                    color: Color.fromARGB(255, 196, 86, 26),
                    size: 48,
                  ),
                ),
                snapshot.data![1],
              ),
            ];
            return Center(
              child: OSMFlutter(
                controller: controller,
                osmOption: OSMOption(
                  staticPoints: staticPoints,
                  zoomOption: ZoomOption(
                    initZoom: 15,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(
                        Icons.person_2,
                        color: Colors.black,
                        size: 72,
                      ),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                  roadConfiguration: RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: MarkerIcon(
                    icon: Icon(
                      Icons.currency_rupee_rounded,
                      color: Colors.blue,
                      size: 56,
                    ),
                  )),
                  // onStaticPointTapped :
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error fetching ATM data');
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
