import 'dart:async';

import 'package:crime_alert_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'authentication_page.dart';
import 'background.dart';
import 'CrimeDetailsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'ChooseTheLocation.dart';
import 'menu_bar.dart';
import 'ChatAuthentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PageController _pageController = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;
  int _selectedIconIndex = -1;
  String selectedCrimeType = '';
  String selectedArea = '';
  List<String> slideUrls = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Timer _timer;

  void fetchSlideUrls() async {
    try {
      QuerySnapshot userFilesSnapshot = await _firestore
          .collection('crime_reports')
          .get();

      List<String> urls = [];

      userFilesSnapshot.docs.forEach((fileDoc) {
        final files = fileDoc.data() as Map<String, dynamic>;
        final List<dynamic> fileUrls = files['fileUrls'];

        for (var fileUrl in fileUrls) {
          urls.add(fileUrl);
        }
      });

      setState(() {
        slideUrls = urls;
      });

     
      startAutoSlideTimer();
    } catch (e) {
      print('Error fetching slide URLs: $e');
    }
  }

  void startAutoSlideTimer() {
    const slideDuration = Duration(seconds: 5); 

    _timer = Timer.periodic(slideDuration, (timer) {
      if (_currentPage < slideUrls.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500), 
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (slideUrls.isEmpty) {
      fetchSlideUrls();
    }
    startAutoSlideTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BackgroundContainer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const Text('Crime Updates', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  height: 300,
                  width: 500,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: slideUrls.length,
                    itemBuilder: (context, index) {
                      final imageUrl = slideUrls[index];
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),
                const Text('If you want to be more specific, click the below button', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CrimeDetailsPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 174, 172, 172),
                  ),
                  child: const Text('More Specific'),
                ),
                const SizedBox(height: 50),
                const Text(
                  'If you want to know based on location, choose the location you want to know the updates about',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationSelectionPage()),
                    );
                  },
                  child: const Text('Choose the Location'),
                ),
              ],
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatAuthenticationPage()),
                  );
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
      ),
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
        _controller.play();
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

