import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

String _apiUrl = '159.253.70.76:5000';

Future<bool> _detect(DetectBreeds detect) async {
  bool success = false;

  try {
    var response = await http.post(Uri.http(_apiUrl, "/imageSend"),
        headers: {}, body: {'image': detect.base64});

    if (response.statusCode == 200) {
      // Decode the json return into a dynamic map so we can access the elements programmatically.
      Map<String, dynamic> decoded = json.decode(response.body);
      for (Map<String, dynamic> iDog in decoded['dog']) {
        Dog dog = new Dog();
        for (Map<String, dynamic> breeds in iDog['breeds'])
          dog.breeds[breeds['breed']] = breeds['certainty'];
        dog.image = iDog['image'];
        detect.results.add(dog);
      }
      // If we hit here everything worked so mark the succe0ss.
      detect.found = detect.results.isNotEmpty;
      success = true;
    } else {
      print(
          'something went wrong, status code: ${response.statusCode.toString()}');
      print(response.body);
    }
  } catch (error) {
    print('An error occured 1');
    print(error.toString());
  }
  return success;
}

Future<DetectBreeds> detect(String base64) async {
  DetectBreeds detectBreeds = new DetectBreeds.withBase64(base64);
  await _detect(detectBreeds);

  return detectBreeds;
}

class DetectBreeds {
  DetectBreeds()
      : found = false,
        results = [];

  DetectBreeds.withBase64(String base64)
      : found = false,
        results = [],
        base64 = base64;

  bool found;
  String base64;
  List<Dog> results;
}

class Dog {
  Dog()
      : dbId = -1,
        breeds = new Map(),
        image = '';
  int dbId;
  Map<String, int> breeds;
  String image;

  Map<String, dynamic> toMap() =>
      <String, dynamic>{'breeds': json.encode(breeds), 'image': image};

  Dog.fromMap(Map<String, dynamic> map) {
    dbId = map['dbId'];
    breeds = Map.from(json.decode(map['breeds']));
    image = map['image'];
  }
}
