import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import '../dbProvider.dart';
import 'library.dart';
import 'confirm.dart';
import 'package:google_fonts/google_fonts.dart';

class Home extends StatefulWidget {
  final List<CameraDescription> initCameras;

  const Home({Key key, this.initCameras}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  List<CameraDescription> cameras;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  File _image;
  bool _cameraOn = true;

  void openGallery(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.getImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        if (_image != null) {
          // Open confirmation
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Confirm(image: _image),
            ),
          );
        }
      });
    }
  }

  Future<void> takePicture() async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      setState(() {
        _cameraOn = true;
      });
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Attempt to take a picture.
      final file = await _controller.takePicture();
      _image = File(file.path);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Attempt to fix the issue of the camera breaking when opening the app from lock screen
    /*if(widget.initCameras == null) {
      availableCameras().then((value) {
        cameras = value;
        initialiseCamera();
      });
    } else {
      cameras = widget.initCameras;
      initialiseCamera();
    }*/

    initialiseCamera();
  }

  @override
  void deactivate() {
    super.deactivate();
    _cameraOn = false;
    //_controller.dispose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraOn = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      print('Paused');
      _cameraOn = false;
    }
    if (state == AppLifecycleState.resumed) {
      print('Resumed');
      _cameraOn = true;
      //_initializeControllerFuture;
    }
    super.didChangeAppLifecycleState(state);
  }

  void initialiseCamera() {
    _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.initCameras
            .first, // change to cameras.first if using the attempted fix above
        // Define the resolution to use.
        ResolutionPreset.medium,
        enableAudio: false);
    _cameraOn = true;
    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    _cameraOn = true;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0.00,
        centerTitle: true,
        title: Text("DOG SCANNER",
            style: GoogleFonts.codaCaption(
              fontSize: 30,
            )),
        //
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return Stack(
              children: <Widget>[
                Center(
                  child: _cameraOn ? CameraPreview(_controller) : Container(),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: (MediaQuery.of(context).size.width /
                              MediaQuery.of(context).size.height) *
                          0.9,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(50, 255, 255, 255),
                            width: 10)),
                  ),
                ),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 4.0,
        color: Colors.teal[700],
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.photo_album),
              onPressed: () {
                DbProvider().read().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Library(dogs: value)));
                });
              },
            ),
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.add_photo_alternate),
              onPressed: () {
                openGallery(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.photo_camera),
        onPressed: () {
          takePicture().then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Confirm(image: _image),
              ),
            );
          });
        },
      ),
    );
  }
}
