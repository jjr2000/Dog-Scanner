import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  double _width = 270;
  double _height = 100;

  void _enlarge() {
    setState(() {
      _width = 270;
    });
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        _width = 300;
      });
      Future.delayed(Duration(milliseconds: 200), () {
        _enlarge();
      });
    });
  }

  /*
  void getData() {
    //simulated, will just use delay, more of a pretty splash screen
    Future.delayed(Duration(seconds: 6), () {
      Navigator.pushNamed(context, '/home');
    });

  }*/

  @override
  void initState() {
    super.initState();
    //getData();
    _enlarge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 400,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.decelerate,
                  width: _width,
                  height: _height,
                  color: Colors.grey[900],
                  child: Image.asset('assets/icons/icon.png'),
                ),
              ),
              SizedBox(
                width: 300,
                height: 100,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  child: Text(
                    'Start Scanning',
                    style: TextStyle(
                      color: Colors.white,
                      //fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(50.0),
                      side: BorderSide(color: Colors.teal[400]),
                    ),
                  ),
                ),
              ),
              TextButton(
                child: Text(
                  'About',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/about');
                },
              ),
            ],
          ),
        ));
  }
}
