import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'authentication_page.dart';
import 'main.dart';
import 'background.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'menu_bar.dart';

class LocationSelectionPage extends StatefulWidget {
  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String selectedArea = '';
  List<CrimeReport> crimeReports = [];

  int _selectedIconIndex = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define a color mapping for different crime types
  final Map<String, Color> crimeTypeColors = {
    'Car theif': Colors.red,
    'Robbery': Colors.blue,
    'voilence': Colors.green,
    'Phone theif': Colors.orange,
    // Add more crime types and colors as needed
  };

  void loadCrimeReports() async {
    if (selectedArea.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('crime_reports')
            .where('area', isEqualTo: selectedArea)
            .get();

        List<CrimeReport> reports = [];
        querySnapshot.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final crimeType = data['crimeType'] as String;
          final latitude = data['latitude'] as double;
          final longitude = data['longitude'] as double;

          reports.add(CrimeReport(
            crimeType: crimeType,
            latitude: latitude,
            longitude: longitude,
          ));
        });

        setState(() {
          crimeReports = reports;
        });
      } catch (e) {
        print('Error fetching crime reports: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 126, 128, 129),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Safe Zone',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crime Updates based on selected area',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 118, 117, 117), ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Select Area in Hyderabad'),
                          value: selectedArea.isNotEmpty ? selectedArea : null,
                          onChanged: (value) {
                            setState(() {
                              selectedArea = value!;
                              loadCrimeReports();
                            });
                          },
                          items: [
                            'Miyapur', 'Koti', 'Secunderabad', 'Charminar'
                          ].map((area) {
                            return DropdownMenuItem<String>(
                              value: area,
                              child: Text(area),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16.0),
                      ],
              
                  ),
                  ),
                ),
                // Display a Google Map here based on the selected area.
                // You can use the Google Maps Flutter package to integrate Google Maps.
                // Add your map widget here.
                Container(
                  width: double.infinity,
                  height: 300, // Adjust the height as needed.
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(17.3850, 78.4867), // Default location.
                      zoom: 14.0,
                    ),
          markers: Set<Marker>.from(
            crimeReports.map((report) {
              return Marker(
                markerId: MarkerId(report.crimeType),
                position: LatLng(report.latitude, report.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet, // Default color
                ),
              );
            }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        color: const Color.fromARGB(255, 244, 175, 118),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    _selectedIconIndex = 0;
                  });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CustomMenuBar()),
              );

                },
              child: Icon(
                Icons.menu,
                color: _selectedIconIndex == 0 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 1;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthenticationPage()),
                );
              },
              child: Icon(
                Icons.report,
                color: _selectedIconIndex == 1 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 2;
                });
                // Implement map functionality.
              },
              child: Icon(
                Icons.map,
                color: _selectedIconIndex == 2 ? Colors.blue : Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _selectedIconIndex = 3;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                );
              },
              child: Icon(
                Icons.home,
                color: _selectedIconIndex == 3 ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CrimeReport {
  final String crimeType;
  final double latitude;
  final double longitude;

  CrimeReport({required this.crimeType, required this.latitude, required this.longitude});
}



class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  VideoPlayerWidget({required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const CircularProgressIndicator();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
