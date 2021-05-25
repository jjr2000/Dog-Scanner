import 'dart:convert';
import 'package:dog_scanner/detect_breed.dart';
import 'package:flutter/material.dart';
import 'package:strings/strings.dart';
import '../dbProvider.dart';

class Library extends StatefulWidget {
  final List<Dog> dogs;

  Library({Key key, @required this.dogs}) : super(key: key);

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: ListView.builder(
          itemCount: widget.dogs.length,
          itemBuilder: (context, index) {
            final Dog dog = widget.dogs[index];
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
              child: Card(
                  color: Colors.grey[850],
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                          width: 100,
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: 1, minHeight: 1),
                            child: Image.memory(base64Decode(dog.image)),
                          )),
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: getBreedsWidgets(dog.breeds)),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_forever),
                        color: Colors.white,
                        onPressed: () {
                          DbProvider().delete(dog.dbId).then((value) {
                            setState(() {
                              widget.dogs.removeAt(index);
                            });
                          });
                        },
                      ),
                    ],
                  )),
            );
          }),
    );
  }

  Widget getBreedsWidgets(Map<String, int> breeds) {
    List<Widget> list = [];
    breeds.forEach((key, value) {
      list.add(new Text(
        "${camelize(key.replaceAll('_', ' '))}: $value%",
        textAlign: TextAlign.left,
        style: key == breeds.keys.first
            ? TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
            : TextStyle(color: Colors.white),
      ));
    });
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }
}
