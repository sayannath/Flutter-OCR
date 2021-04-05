import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

enum AppState {
  free,
  picked,
  cropped,
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppState state;
  File _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    state = AppState.free;
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        setState(() {
          state = AppState.picked;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR App'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          if (state == AppState.free) {
            getImage();
          } else if (state == AppState.picked)
            cropImage();
          else if (state == AppState.cropped) getText();
        },
        child: buildButtonIcon(),
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
                  : Container(
                      height: 300, width: 300, child: Image.file(_image)),
              SizedBox(height: 20),
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
                          prefixIcon:
                              Icon(Icons.text_fields, color: Colors.white),
                          focusColor: Colors.black26,
                          fillColor: Colors.black26,
                          filled: true,
                          hintText: "Address",
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButtonIcon() {
    if (state == AppState.free)
      return Icon(
        Icons.add,
        color: Colors.white,
      );
    else if (state == AppState.picked)
      return Icon(
        Icons.crop,
        color: Colors.white,
      );
    else if (state == AppState.cropped)
      return Icon(
        Icons.arrow_right,
        color: Colors.white,
      );
    else
      return Container();
  }

  Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _image.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop the Image',
            toolbarColor: Color(0xff375079),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      _image = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void getText() async {
    await readText(_image);
    setState(() {
      state = AppState.free;
    });
  }
}
