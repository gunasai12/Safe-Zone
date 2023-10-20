import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'authentication_page.dart';
import 'main.dart';
import 'background.dart';
import 'menu_bar.dart';

class CrimeReportingPage extends StatefulWidget {
  @override
  _CrimeReportingPageState createState() => _CrimeReportingPageState();
}

class _CrimeReportingPageState extends State<CrimeReportingPage> {
  int _selectedIconIndex = 1;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController addressController = TextEditingController();
  String selectedCrimeType = '';
  String selectedArea = '';
  FilePickerResult? filePickerResult;
  List<PlatformFile> selectedFiles = [];
  String errorText = '';

  List<String?> crimeTypes = ['Car theif','Robbery', 'voilence','Phone theif'];
  List<String?> areasInHyderabad = ['Miyapur', 'Koti', 'Secunderabad', 'Charminar'];

  // Predefined latitude and longitude values for each area
  Map<String, Map<String, double>> areaCoordinates = {
    'Miyapur': {'latitude': 17.4958, 'longitude': 78.3522},
    'Koti': {'latitude': 17.3850, 'longitude': 78.4867},
    'Secunderabad': {'latitude': 17.4339, 'longitude': 78.5136},
    'Charminar': {'latitude': 17.3616, 'longitude': 78.4747},
  };

  void clearErrorText() {
    setState(() {
      errorText = '';
    });
  }

  Future<List<String>> uploadFiles(List<PlatformFile> files, String userId) async {
    List<String> fileUrls = [];

    try {
      for (PlatformFile file in files) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('userFiles/$userId/${file.name}');
        final UploadTask uploadTask =
            storageRef.putFile(File(file.path!)); // Extract file path.

        // Add debug statement
        print('Uploading file: ${file.name}');

        await uploadTask.whenComplete(() async {
          final String downloadUrl = await storageRef.getDownloadURL();
          fileUrls.add(downloadUrl);
          // Add debug statement
          print('File uploaded: $downloadUrl');
        });
      }
    } catch (e) {
      print('Error uploading files: $e');
    }

    return fileUrls;
  }

  Future<void> submitReport() async {
    if (selectedCrimeType.isEmpty ||
        selectedArea.isEmpty ||
        addressController.text.isEmpty ||
        selectedFiles.isEmpty) {
      setState(() {
        errorText = 'Please fill in all fields and upload any proof';
      });
      return;
    }

    String userId = _auth.currentUser!.uid;

    List<String> fileUrls = await uploadFiles(selectedFiles, userId);

    // Get the latitude and longitude for the selected area
    final Map<String, double> coordinates = areaCoordinates[selectedArea] ?? {};

    // Ensure that latitude and longitude are available
    if (coordinates.isEmpty) {
      setState(() {
        errorText = 'Coordinates for the selected area are not available.';
      });
      return;
    }

    await _firestore.collection('crime_reports').add({
      'userId': userId,
      'crimeType': selectedCrimeType,
      'area': selectedArea,
      'address': addressController.text,
      'fileUrls': fileUrls,
      'latitude': coordinates['latitude'],
      'longitude': coordinates['longitude'],
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Submitted'),
          content: const Text('Your report has been submitted successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Crime Report',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 118, 117, 117)),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5, // Add elevation to the card
                  margin: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        DropdownButton<String?>(
                          hint: const Text('Select Crime Type'),
                          value: selectedCrimeType.isNotEmpty
                              ? selectedCrimeType
                              : null,
                          onChanged: (value) {
                            setState(() {
                              selectedCrimeType = value!;
                              clearErrorText();
                            });
                          },
                          items: crimeTypes.map((crimeType) {
                            return DropdownMenuItem<String?>(
                              value: crimeType,
                              child: Text(crimeType ?? ''),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16.0),
                        DropdownButton<String?>(
                          hint: const Text('Select Area in Hyderabad'),
                          value: selectedArea.isNotEmpty ? selectedArea : null,
                          onChanged: (value) {
                            setState(() {
                              selectedArea = value!;
                              clearErrorText();
                            });
                          },
                          items: areasInHyderabad.map((area) {
                            return DropdownMenuItem<String?>(
                              value: area,
                              child: Text(area ?? ''),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: addressController,
                          decoration: InputDecoration(
                            labelText: 'Address of Crime Location',
                            errorText: errorText.isNotEmpty ? errorText : null,
                          ),
                          onChanged: (value) {
                            clearErrorText();
                          },
                        ),
                        const SizedBox(height: 22),
                        const Text(
                            'Click the below button to upload your proof (jpg, jpeg, png, mp3, etc.)',
                            style: TextStyle(fontSize: 13),
                            textAlign: TextAlign.center),
                        ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? files =
                                await FilePicker.platform.pickFiles(
                              allowMultiple: true,
                              type: FileType.custom,
                              allowedExtensions: [
                                'jpg',
                                'jpeg',
                                'png',
                                'mp3',
                              ],
                            );
                            if (files != null) {
                              setState(() {
                                selectedFiles = files.files;
                              });
                            }
                          },
                          child: const Text('Select Files'),
                        ),
                        const SizedBox(height: 8.0),
                        if (selectedFiles.isNotEmpty)
                          Column(
                            children: selectedFiles.map((file) {
                              return Text(file.name);
                            }).toList(),
                          ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            submitReport();
                          },
                          child: const Text('Submit Report'),
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
