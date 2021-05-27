import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../detect_breed.dart';
import '../dbProvider.dart';
import 'library.dart';

class WebRequestLoading extends StatefulWidget {
  final String base;

  const WebRequestLoading({Key key, @required this.base}) : super(key: key);

  @override
  _WebRequestLoadingState createState() => _WebRequestLoadingState();
}

class _WebRequestLoadingState extends State<WebRequestLoading> {
  String error = "";

  void _doSearch(String base) async {
    DetectBreeds response = await detect(widget.base);
    if (response.found) {
      print(response.results);
      // Dog has been found, add it into the db
      for (Dog dog in response.results) {
        await DbProvider().insert(dog);
      }
      DbProvider().read().then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Library(dogs: value)));
      });
    } else {
      // Tell the user their image was shit and have them retake it.
      error =
          "Detection error. Please make sure your pupper is well lit and staying nice and still while taking the photo.";
      Navigator.pop(context);
      _showDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    _doSearch(widget.base);
  }

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Oops!',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  error,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Let\'s try again!'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: error == ""
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: 300,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: LinearProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                        "Please wait while our expert panel of doggos work this one out for you hooman!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                ],
              ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(error),
                    TextButton(
                      child: Text("Back"),
                      onPressed: () {},
                    )
                  ],
                ),
              ));
  }
}
