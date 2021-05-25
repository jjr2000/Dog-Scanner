import 'dart:io';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'loading.dart';

class Confirm extends StatefulWidget {
  final File image;

  const Confirm({Key key, @required this.image}) : super(key: key);

  @override
  _ConfirmState createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Container(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                    child: Image.file(
                      widget.image,
                      fit: BoxFit.fitWidth,
                    )
                ),
              ],
            ),
            Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 30.0, left: 10.0),
                  child: IconButton(
                    iconSize: 30.0,
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[800],
        child: Icon(Icons.check),
        onPressed: () {
          List<int> imageBytes = widget.image.readAsBytesSync();
          // Decode data for processing
          img.Image image = img.decodeImage(imageBytes);
          // Rescale image
          img.Image resized = img.copyResize(image, width: 381);
          // Encode image data into jpg represented as a base65 url safe string
          String base = base64Encode(img.encodeJpg(resized));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebRequestLoading(base: base),
            )
          );
        },
      ),
    );
  }
}



