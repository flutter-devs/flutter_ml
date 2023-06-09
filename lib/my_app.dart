import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ml_demo/core/common_utils.dart';
import 'package:flutter_ml_demo/widgets/app_button.dart';
import 'package:flutter_ml_demo/widgets/custom_app_bar.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';



class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // static const Color bgColor = Color(0xFFEFEFEF);
  String backgroundImage = "assets/images/background.jpg";
  ImagePicker imagePicker = ImagePicker();
  File? _image;
  double? _imageWidth;
  double? _imageHeight;
  var _recognitions;

  loadModel() async {
    Tflite.close();
    try {
      String? res = await Tflite.loadModel(
          model: "assets/model_unquant.tflite",
          labels: "assets/labels.txt",
          numThreads: 2,
          isAsset: true,
          useGpuDelegate: false);
      debugPrint("RES:- $res");
    } on PlatformException {
      debugPrint("Failed to load the model");
    }
  }

  // run prediction using TFLite on given image
  Future predict(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.6,
        asynch: true // defaults to true
    );

    debugPrint("Recognitions:--$recognitions");

    setState(() {
      _recognitions = recognitions;
    });
  }

  // send image to predict method selected from gallery or camera
  sendImage(File image) async {
    // if(image == null) return;
    await predict(image);

    // get the width and height of selected image
    FileImage(image)
        .resolve(const ImageConfiguration())
        .addListener((ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageWidth = info.image.width.toDouble();
        _imageHeight = info.image.height.toDouble();
        _image = image;
      });
    })));
  }

  // select image from gallery
  selectFromGallery() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() {});
    File fileImage = await CommonUtils.convertXFileToFile(image);
    sendImage(fileImage);
  }

  // select image from camera
  selectFromCamera() async {
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    setState(() {});
    File fileImage = await CommonUtils.convertXFileToFile(image);
    sendImage(fileImage);
  }

  @override
  void initState() {
    super.initState();

    loadModel().then((val) {
      setState(() {});
    });
  }

  Widget printValue(rcg) {
    if (rcg == null) {
      return const Text('',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700));
    } else if (rcg.isEmpty) {
      return const Center(
        child: Text("Could not recognize",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Prediction: ",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Colors.teal.shade50),
            ),
            Text(
              _recognitions[0]['label'].toString().substring(2).toUpperCase(),
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Colors.pinkAccent.shade100),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    double finalW;
    double finalH;

    if (_imageWidth == null && _imageHeight == null) {
      finalW = size.width;
      finalH = size.height;
    } else {
      double ratioW = size.width / _imageWidth!;
      double ratioH = size.height / _imageHeight!;

      finalW = _imageWidth! * ratioW * .85;
      finalH = _imageHeight! * ratioH * .50;
    }

//    List<Widget> stackChildren = [];

    return Scaffold(
        appBar: CustomAppBar(CustomAppBarAttributes(
            title: "Recognition Test", trailing: const Icon(Icons.more_vert))),
        body: Stack(
            children: [
              SizedBox(
                height: size.height,
                width: size.width,
                child: Image.asset(backgroundImage, fit: BoxFit.fill),
              ),
              ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: printValue(_recognitions),
                  ),
                  Stack(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 30),
                        child: Container(
                          height: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 7, color: Colors.teal),
                          ),
                          child: _image == null
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<void>(
                                  future: precacheImage(
                                      const NetworkImage(
                                          "https://img.pikbest.com/png-images/qiantu/hand-drawn-cartoon-girl-wearing-glasses_2720821.png!bwr800"),
                                      context),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<void> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // While the image is loading, show a CircularProgressIndicator
                                      return const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      );
                                    } else if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      // If the image is loaded, display it using Image.network
                                      return Image.network(
                                        "https://img.pikbest.com/png-images/qiantu/hand-drawn-cartoon-girl-wearing-glasses_2720821.png!bwr800",
                                        height: 100,
                                        width: 100,
                                      );
                                    } else {
                                      // Handle error or other states here
                                      return const Text('Error loading image');
                                    }
                                  },
                                ),
                                Text(
                                  "Do you wear specs? Let's check!",
                                  style: TextStyle(
                                      backgroundColor: Colors.teal.shade50),
                                ),
                              ],
                            ),
                          )
                              : Center(
                              child: Image.file(
                                _image!,
                                fit: BoxFit.fill,
                                width: finalW,
                                height: finalH,
                              )),
                        )),
                    Positioned(
                        right: 20,
                        child: Visibility(
                          visible: _image != null,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _image = null;
                                _recognitions = null;
                              });
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.pinkAccent.shade100,
                              size: 30,
                            ),
                          ),
                        ))
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                          child: AppButton(
                            color: Colors.pinkAccent,
                            icon: Icons.camera_alt,
                            onTap: selectFromCamera,
                          )),
                      AppButton(
                          onTap: selectFromGallery,
                          color: Colors.teal,
                          icon: Icons.upload),
                    ],
                  ),
                ],
              ),
            ]
        ));
  }

}