import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'authentication_page.dart';
import 'main.dart';
import 'background.dart';
import 'package:video_player/video_player.dart'; 
import 'menu_bar.dart';

class CrimeDetailsPage extends StatefulWidget {
  @override
  _CrimeDetailsPageState createState() => _CrimeDetailsPageState();
}

class _CrimeDetailsPageState extends State<CrimeDetailsPage> {
  String selectedCrimeType = '';
  String selectedArea = '';
  List<CrimeReport> crimeReports = [];

  int _selectedIconIndex = 3;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void loadUploadedFiles() async {
    if (selectedCrimeType.isNotEmpty && selectedArea.isNotEmpty) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('crime_reports')
            .where('crimeType', isEqualTo: selectedCrimeType)
            .where('area', isEqualTo: selectedArea)
            .get();

        List<CrimeReport> reports = [];
        querySnapshot.docs.forEach((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fileUrls = data['fileUrls'] as List<dynamic>;
          final crimeType = data['crimeType'] as String;
          final area = data['area'] as String;

          reports.add(CrimeReport(
            crimeType: crimeType,
            area: area,
            fileUrls: fileUrls.cast<String>(),
          ));
        });

        setState(() {
          crimeReports = reports;
        });
      } catch (e) {
        print('Error fetching files: $e');
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
                  'Crime Updates based on preferences',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 118, 117, 117), ),textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5, // Add elevation to the card
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Select Crime Type'),
                          value: selectedCrimeType.isNotEmpty ? selectedCrimeType : null,
                          onChanged: (value) {
                            setState(() {
                              selectedCrimeType = value!;
                          
                              loadUploadedFiles();
                            });
                          },
                       
                          items: ['Car theif','Robbery', 'voilence','Phone theif'].map((crimeType) {
                            return DropdownMenuItem<String>(
                              value: crimeType,
                              child: Text(crimeType),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButton<String>(
                          hint: const Text('Select Area in Hyderabad'),
                          value: selectedArea.isNotEmpty ? selectedArea : null,
                          onChanged: (value) {
                            setState(() {
                              selectedArea = value!;
                             
                              loadUploadedFiles();
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

                        const SizedBox(height: 16.0),
                       
                        Column(
                          children: crimeReports.map((report) {
                            return CrimeReportWidget(report: report);
                          }).toList(),
                        ),
                      ],
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
  final String area;
  final List<String> fileUrls;

  CrimeReport({required this.crimeType, required this.area, required this.fileUrls});
}

class CrimeReportWidget extends StatelessWidget {
  final CrimeReport report;

  CrimeReportWidget({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Crime Type: ${report.crimeType}',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Area: ${report.area}',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        // Display images or videos associated with the crime report.
        Column(
          children: report.fileUrls.map((fileUrl) {
            if (fileUrl.endsWith('.jpg') || fileUrl.endsWith('.jpeg') || fileUrl.endsWith('.png') || fileUrl.endsWith('.psd')) {
              // If the URL is an image, display it using the Image widget.
              return Image.network(
                fileUrl,
                width: 200, // Set the width and height as needed.
                height: 200,
              );
            } else if (fileUrl.endsWith('.mp4') || fileUrl.endsWith('.avi')) {
              // If the URL is a video, display it using the VideoPlayerWidget.
              return VideoPlayerWidget(
                videoUrl: fileUrl,
              );
            } else {
              // If it's not an image or video, display the URL as text.
              return Text(
                fileUrl,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.blue,
                ),
              );
            }
          }).toList(),
        ),
      ],
    );
  }
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
        // Ensure the first frame is shown and play the video.
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
        : const CircularProgressIndicator(); // Display a loading indicator while the video is loading.
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
