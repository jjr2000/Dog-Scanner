import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Image.asset(
                  'assets/icons/icon.png',
                  height: 200,
                ),
              ),
            ),
            Text("DOG SCANNER",
                style:
                    GoogleFonts.codaCaption(fontSize: 30, color: Colors.white)),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Whether you have a doggo, pupper, woofer or floofer, every hooman endevours to know the breed of their furry friend! Dog Scanner aims to answer this question. Using cutting edge computer vision, machine learning and neural network techonology, Dog Scanner will make a best guess estimate of what breed (or mix of breeds) your doggo is.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
