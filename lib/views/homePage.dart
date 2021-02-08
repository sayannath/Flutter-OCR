import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  TextEditingController script = TextEditingController();

  Future readText(File image) async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(image);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    script.clear();
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            script.text = script.text + " " + word.text;
          });
        }
        script.text = script.text + '\n';
      }
    }
    setState(() {});
  }

  _launchURL(String text) async {
    var url = 'https://www.google.com/search?q=$text&tbm=isch';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          setState(() {
            script.clear();
          _image = null;
          });
          await getImage();
        },
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [              
              SizedBox(height: 20),
              _image == null
                  ? Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    )
                  : Container(height: 300, width: 300, child: Image.file(_image)),
              SizedBox(height: 20),
              Visibility(
                visible: _image == null && script.text.length == 0 ? false : true,
                child: SizedBox(
                  width: 200,
                  child: RaisedButton(
                    onPressed: () async {
                      await readText(_image);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Get Text"),
                  ),
                ),
              ),
              script.text != null
                  ? Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: TextFormField(
                        controller: script,
                        minLines: 5,
                        maxLines: 100,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        onChanged: (val) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.text_fields, color: Colors.white),
                          focusColor: Colors.black26,
                          fillColor: Colors.black26,
                          filled: true,
                          hintText: "Enter your resume script!",
                          hintStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.white60,
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.white60,
                              width: 4.0,
                            ),
                          ),
                        ),
                      ),
                  )
                  : Text("No Text found"),
              SizedBox(height: 20),
              Visibility(
                visible: _image == null && script.text.length == 0 ? false : true,
                child: SizedBox(
                  width: 200,
                  child: RaisedButton(
                    onPressed: () {
                      _launchURL(script.text);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text("Search"),
                  ),
                ),
              ),              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
